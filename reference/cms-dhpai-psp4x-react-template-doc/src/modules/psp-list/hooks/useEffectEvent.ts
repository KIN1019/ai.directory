import { useRef, useCallback } from "react";

/**
 * A polyfill for React 19's useEffectEvent.
 * Returns a stable function that always calls the latest callback.
 * Use this to read latest props/state in effects without adding them to dependencies.
 *
 * @example
 * const onScroll = useEffectEvent((delta: number) => {
 *   // Always has access to latest props/state
 *   console.log(delta, latestValue);
 * });
 *
 * useEffect(() => {
 *   element.addEventListener('scroll', onScroll);
 *   return () => element.removeEventListener('scroll', onScroll);
 * }, []); // onScroll is stable, no need in deps
 */
export function useEffectEvent<T extends (...args: never[]) => unknown>(
	callback: T,
): T {
	const ref = useRef(callback);
	ref.current = callback;

	return useCallback(((...args) => ref.current(...args)) as T, []);
}
