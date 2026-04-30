import { useState, useCallback, MouseEvent } from "react";

export interface ContextMenuPosition {
	mouseX: number;
	mouseY: number;
}

export interface UseContextMenuReturn {
	/** Current context menu position, or null if closed */
	contextMenuPosition: ContextMenuPosition | null;
	/** Handler for right-click events */
	handleContextMenu: (event: MouseEvent<HTMLElement>) => void;
	/** Close the context menu */
	handleCloseContextMenu: () => void;
}

/**
 * Hook to manage context menu state and positioning.
 *
 * @example
 * ```tsx
 * const { contextMenuPosition, handleContextMenu, handleCloseContextMenu } = useContextMenu();
 *
 * return (
 *   <div onContextMenu={handleContextMenu}>
 *     <GridContextMenu
 *       open={contextMenuPosition !== null}
 *       position={contextMenuPosition}
 *       onClose={handleCloseContextMenu}
 *     />
 *   </div>
 * );
 * ```
 */
export function useContextMenu(): UseContextMenuReturn {
	const [contextMenuPosition, setContextMenuPosition] =
		useState<ContextMenuPosition | null>(null);

	const handleContextMenu = useCallback((event: MouseEvent<HTMLElement>) => {
		event.preventDefault();
		event.stopPropagation();

		setContextMenuPosition({
			mouseX: event.clientX,
			mouseY: event.clientY,
		});
	}, []);

	const handleCloseContextMenu = useCallback(() => {
		setContextMenuPosition(null);
	}, []);

	return {
		contextMenuPosition,
		handleContextMenu,
		handleCloseContextMenu,
	};
}
