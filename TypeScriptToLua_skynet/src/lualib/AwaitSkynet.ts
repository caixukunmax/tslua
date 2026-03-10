// Skynet-compatible version of async awaiter
// Uses skynet.fork to create coroutines in Skynet's scheduler
//
// This is a drop-in replacement for Await.ts when running in Skynet environment.
// The key difference is using skynet.fork to wrap coroutine creation, ensuring
// compatibility with Skynet's message loop and coroutine management.

import { __TS__Promise } from "./Promise";

const coroutine = _G.coroutine ?? {};
const cocreate = coroutine.create;
const coresume = coroutine.resume;
const costatus = coroutine.status;
const coyield = coroutine.yield;

// Try to get skynet module (will be nil if not in Skynet environment)
const skynet = _G.package?.loaded?.["skynet"] ?? (_G as any).skynet;

// Be extremely careful editing this function. A single non-tail function call may ruin chained awaits performance
// eslint-disable-next-line @typescript-eslint/promise-function-async
export function __TS__AsyncAwaiter(this: void, generator: (this: void) => void) {
    return new Promise((resolve, reject) => {
        let resolved = false;
        let asyncCoroutine: any;

        function fulfilled(value: unknown): void {
            const [success, resultOrError] = coresume(asyncCoroutine, value);
            if (success) {
                // `step` never throws. Tail call return is important!
                return step(resultOrError);
            }
            // `reject` should never throw. Tail call return is important!
            return reject(resultOrError);
        }

        function step(this: void, result: unknown): void {
            if (resolved) {
                return;
            }
            if (costatus(asyncCoroutine) === "dead") {
                // `resolve` never throws. Tail call return is important!
                return resolve(result);
            }
            // We cannot use `then` because we need to avoid calling `coroutine.resume` from inside `pcall`
            // `fulfilled` and `reject` should never throw. Tail call return is important!
            return __TS__Promise.resolve(result).addCallbacks(fulfilled, reject);
        }

        // Key difference from standard Await.ts:
        // Use skynet.fork to wrap the coroutine creation in Skynet's scheduler
        // This ensures the coroutine runs in Skynet's message loop context
        const startCoroutine = () => {
            asyncCoroutine = cocreate(generator);
            const [success, resultOrError] = coresume(asyncCoroutine, (v: unknown) => {
                resolved = true;
                return __TS__Promise.resolve(v).addCallbacks(resolve, reject);
            });
            if (success) {
                return step(resultOrError);
            } else {
                return reject(resultOrError);
            }
        };

        // If skynet.fork is available, use it to start the coroutine
        // Otherwise fall back to direct execution (for non-Skynet environments)
        if (skynet && typeof (skynet as any).fork === "function") {
            (skynet as any).fork(startCoroutine);
        } else {
            startCoroutine();
        }
    });
}

export function __TS__Await(this: void, thing: unknown) {
    return coyield(thing);
}
