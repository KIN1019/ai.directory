/**
 * Simple scroll acceleration: small deltas stay small, large deltas get boosted.
 */

export interface ScrollAccelerationConfig {
	/** Delta threshold - the midpoint between slow and fast. Default: 50 */
	threshold: number;
	/** Multiplier for slow/small deltas (< threshold). Default: 0.5 */
	minMultiplier: number;
	/** Maximum multiplier for large deltas. Default: 2.5 */
	maxMultiplier: number;
}

export const DEFAULT_ACCELERATION_CONFIG: ScrollAccelerationConfig = {
	threshold: 50,
	minMultiplier: 0.5,
	maxMultiplier: 2.5,
};

/**
 * Creates a scroll accelerator that boosts large scroll deltas.
 */
export function createScrollAccelerator(
	config: Partial<ScrollAccelerationConfig> = {},
) {
	const { threshold, minMultiplier, maxMultiplier } = {
		...DEFAULT_ACCELERATION_CONFIG,
		...config,
	};

	function getAcceleratedDelta(rawDelta: number): number {
		const absDelta = Math.abs(rawDelta);

		if (absDelta <= threshold) {
			// Slow zone: dampen small deltas
			const ratio = absDelta / threshold;
			const multiplier = minMultiplier + (1 - minMultiplier) * ratio; // ramp from min to 1
			return rawDelta * multiplier;
		}

		// Fast zone: progressive acceleration
		const ratio = Math.min((absDelta - threshold) / (threshold * 2), 1);
		const multiplier = 1 + (maxMultiplier - 1) * ratio * ratio;
		return rawDelta * multiplier;
	}

	// No-op, kept for API compatibility
	function reset(): void {}

	return {
		getAcceleratedDelta,
		reset,
	};
}

export type ScrollAccelerator = ReturnType<typeof createScrollAccelerator>;
