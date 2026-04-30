import { useRef, createRef } from "react";
import type { GridApi } from "@mui/x-data-grid-pro";

/**
 * Custom hook to create and maintain stable API refs for N panels.
 * Returns refs typed for use with DataGrid's apiRef prop.
 *
 * @param count - Number of refs to maintain
 * @returns Array of mutable refs for grid API instances
 */
export function useApiRefs(count: number): React.MutableRefObject<GridApi>[] {
	// Create refs once and store them
	const refsRef = useRef<React.MutableRefObject<GridApi>[]>([]);

	// Adjust refs array if count changes
	if (refsRef.current.length !== count) {
		// Preserve existing refs where possible
		const newRefs: React.MutableRefObject<GridApi>[] = [];
		for (let i = 0; i < count; i++) {
			// Reuse existing ref or create new one
			// Cast is safe: MUI's DataGrid will populate the ref value
			newRefs.push(
				refsRef.current[i] ??
					(createRef() as unknown as React.MutableRefObject<GridApi>),
			);
		}
		refsRef.current = newRefs;
	}

	return refsRef.current;
}
