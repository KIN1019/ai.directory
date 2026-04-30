import { useCallback, useRef, useEffect } from "react";
import { Box } from "@mui/material";

interface DraggableDividerProps {
	onDrag: (deltaX: number) => void;
	onDragEnd?: () => void;
}

/**
 * A draggable vertical divider for resizing split panels.
 */
export function DraggableDivider({ onDrag, onDragEnd }: DraggableDividerProps) {
	const isDraggingRef = useRef(false);
	const startXRef = useRef(0);

	const handleMouseDown = useCallback((e: React.MouseEvent) => {
		e.preventDefault();
		isDraggingRef.current = true;
		startXRef.current = e.clientX;
		document.body.style.cursor = "col-resize";
		document.body.style.userSelect = "none";
	}, []);

	useEffect(() => {
		const handleMouseMove = (e: MouseEvent) => {
			if (!isDraggingRef.current) return;

			const deltaX = e.clientX - startXRef.current;
			startXRef.current = e.clientX;
			onDrag(deltaX);
		};

		const handleMouseUp = () => {
			if (isDraggingRef.current) {
				isDraggingRef.current = false;
				document.body.style.cursor = "";
				document.body.style.userSelect = "";
				onDragEnd?.();
			}
		};

		document.addEventListener("mousemove", handleMouseMove);
		document.addEventListener("mouseup", handleMouseUp);

		return () => {
			document.removeEventListener("mousemove", handleMouseMove);
			document.removeEventListener("mouseup", handleMouseUp);
		};
	}, [onDrag, onDragEnd]);

	return (
		<Box
			onMouseDown={handleMouseDown}
			sx={{
				width: 6,
				minWidth: 6,
				backgroundColor: "#c0c0c0",
				cursor: "col-resize",
				display: "flex",
				alignItems: "center",
				justifyContent: "center",
				flexShrink: 0,
				"&:hover": {
					backgroundColor: "#a0a0a0",
				},
				"&::before": {
					content: '""',
					width: 2,
					height: 24,
					backgroundColor: "#808080",
					borderRadius: 1,
				},
			}}
		/>
	);
}
