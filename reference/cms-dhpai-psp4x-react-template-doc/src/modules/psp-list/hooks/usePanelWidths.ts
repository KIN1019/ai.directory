import { useState, useCallback } from "react";
import { type ResolvedPanel, LAST_PANEL_MIN_WIDTH } from "../types";

interface UsePanelWidthsResult {
	/** Current widths for each non-last panel */
	panelWidths: number[];
	/** Creates a drag handler for a specific panel divider */
	createDividerDragHandler: (panelIndex: number) => (deltaX: number) => void;
}

/**
 * Hook to manage panel widths and divider drag interactions.
 *
 * Handles:
 * - Initial width state based on panel configs
 * - Drag handler creation for dividers
 * - Width constraints (min/max) during resizing
 *
 * @param resolvedPanels - Array of resolved panel configurations
 * @param containerRef - Ref to the container element for width calculations
 * @returns Panel widths state and drag handler factory
 */
export function usePanelWidths(
	resolvedPanels: ResolvedPanel[],
	containerRef: React.RefObject<HTMLDivElement | null>,
): UsePanelWidthsResult {
	const panelCount = resolvedPanels.length;

	// Panel width state: array of widths for non-last panels
	const [panelWidths, setPanelWidths] = useState<number[]>(() =>
		resolvedPanels.slice(0, -1).map((p) => p.initialWidth),
	);

	// Create drag handlers for each divider
	const createDividerDragHandler = useCallback(
		(panelIndex: number) => (deltaX: number) => {
			setPanelWidths((prevWidths) => {
				const containerWidth = containerRef.current?.offsetWidth ?? 800;
				const newWidths = [...prevWidths];

				// Validate panel index
				const panel = resolvedPanels[panelIndex];
				const currentWidth = newWidths[panelIndex];
				if (panel === undefined || currentWidth === undefined) {
					return prevWidths;
				}

				// Calculate constraints for this panel
				const dividerWidth = 6; // DraggableDivider width
				const totalDividerWidth = dividerWidth * (panelCount - 1);
				const minWidth = panel.minWidth;

				// Max width: ensure last panel keeps its minimum
				const otherFixedWidths = newWidths.reduce(
					(sum, w, i) => (i === panelIndex ? sum : sum + w),
					0,
				);
				const maxWidth =
					containerWidth -
					otherFixedWidths -
					totalDividerWidth -
					LAST_PANEL_MIN_WIDTH;

				const newWidth = Math.min(
					Math.max(currentWidth + deltaX, minWidth),
					maxWidth,
				);
				newWidths[panelIndex] = newWidth;

				return newWidths;
			});
		},
		[panelCount, resolvedPanels, containerRef],
	);

	return { panelWidths, createDividerDragHandler };
}
