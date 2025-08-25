import { useReducer, useEffect } from "react";

type SelectionReducerAction =
	| ["INCREMENT"]
	| ["DECREMENT"]
	| ["RESET"]
	| ["SET", number];

const getSelectionReducer =
	(max: number) => (state: number, action: SelectionReducerAction) => {
		switch (action[0]) {
			case "INCREMENT":
				return Math.min(max, state + 1);
			case "DECREMENT":
				return Math.max(0, state - 1);
			case "SET":
				return action[1];
			case "RESET":
				return 0;
		}
	};

function useSelection(
	max: number = Infinity,
	callback: (index: number) => void = () => {},
) {
	const [selectedIndex, selectedIndexDispatch] = useReducer(
		getSelectionReducer(max),
		0,
	);

	const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
		switch (e.key) {
			case "ArrowDown":
				e.preventDefault();
				selectedIndexDispatch(["INCREMENT"]);
				break;
			case "ArrowUp":
				e.preventDefault();
				selectedIndexDispatch(["DECREMENT"]);
				break;
			case "Enter":
				e.preventDefault();
				callback(selectedIndex);
				break;
		}
	};

	return {
		selectedIndex,
		selectedIndexDispatch,
		handleKeyDown,
	};
}

export { useSelection };
