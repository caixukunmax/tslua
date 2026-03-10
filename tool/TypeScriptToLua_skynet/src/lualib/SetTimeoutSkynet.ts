/** @noSelfInFile */
// Skynet-compatible version of setTimeout
// Uses skynet.timeout + skynet.fork for coroutine-safe scheduling
//
// This is a drop-in replacement for setTimeout when running in Skynet environment.
// The key difference is using skynet.fork to wrap the callback, ensuring
// compatibility with Skynet's message loop and coroutine management.

// Declare skynet with this: void methods to ensure dot notation
interface SkynetApi {
    fork: (this: void, fn: () => void) => void;
    timeout: (this: void, ms: number, fn: () => void) => void;
    error: (this: void, msg: string) => void;
}

// Dynamic skynet getter - must be called at runtime, not module load time
// This ensures _G.skynet is available after ts_bootstrap.lua injection
function getSkynet(): SkynetApi | undefined {
    return (_G as any).package?.loaded?.["skynet"] ?? (_G as any).skynet;
}

/**
 * Skynet-safe setTimeout
 * Uses skynet.timeout for timing and skynet.fork for coroutine-safe callback execution
 */
export function __TS__setTimeoutSkynet(this: void, callback: (...args: any[]) => void, delay?: number): number {
    const skynet = getSkynet();
    if (!skynet || typeof skynet.timeout !== "function") {
        // Fallback: no scheduling available in this environment
        return 0;
    }

    const centiseconds = Math.floor((delay ?? 0) / 10);
    let timerId = 0;

    skynet.timeout(centiseconds, () => {
        // Use skynet.fork to wrap the callback in a managed coroutine
        // This ensures async/await inside the callback works correctly
        if (typeof skynet.fork === "function") {
            skynet.fork(() => {
                try {
                    callback();
                } catch (err) {
                    skynet.error(`[setTimeout] Callback error: ${err}`);
                }
            });
        } else {
            // No fork available, execute directly (may cause coroutine issues)
            try {
                callback();
            } catch (err) {
                skynet.error(`[setTimeout] Callback error: ${err}`);
            }
        }
    });

    return timerId;
}

/**
 * Skynet-safe setImmediate
 * Equivalent to setTimeout(callback, 0)
 */
export function __TS__setImmediateSkynet(this: void, callback: (...args: any[]) => void): number {
    return __TS__setTimeoutSkynet(callback, 0);
}

/**
 * Skynet-safe clearTimeout
 * Note: Skynet does not support canceling timeouts
 * This is a no-op for API compatibility
 */
export function __TS__clearTimeoutSkynet(this: void, _handle: number): void {
    // Skynet does not support canceling timeouts
    // The callback will still execute, but can check a cancellation flag
}
