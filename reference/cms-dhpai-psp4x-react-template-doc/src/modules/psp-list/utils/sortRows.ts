/**
 * Generic sorting utilities - framework agnostic
 */

/**
 * Sort direction for a column
 */
export type SortDirection = "asc" | "desc" | null | undefined;

/**
 * A single sort item specifying field and direction
 */
export interface SortItem {
	field: string;
	sort: SortDirection;
}

/**
 * Sort model - array of sort items for multi-column sorting
 */
export type SortModel = readonly SortItem[];

/**
 * Row reference passed to sort comparator
 */
export interface SortRowRef<T> {
	id: unknown;
	row: T;
}

/**
 * Custom sort comparator function type
 */
export type SortComparator<T = unknown> = (
	valueA: T,
	valueB: T,
	rowRefA: SortRowRef<unknown>,
	rowRefB: SortRowRef<unknown>,
) => number;

/**
 * Column configuration for sorting
 */
export interface ColumnSortConfig {
	field: string;
	sortComparator?: SortComparator;
}

/**
 * Default comparison logic for values
 */
export function defaultCompare(valueA: unknown, valueB: unknown): number {
	if (valueA == null && valueB == null) {
		return 0;
	}
	if (valueA == null) {
		return 1;
	}
	if (valueB == null) {
		return -1;
	}
	if (typeof valueA === "string" && typeof valueB === "string") {
		return valueA.localeCompare(valueB);
	}
	if (typeof valueA === "number" && typeof valueB === "number") {
		return valueA - valueB;
	}
	if (typeof valueA === "boolean" && typeof valueB === "boolean") {
		return valueA === valueB ? 0 : valueA ? -1 : 1;
	}
	if (valueA instanceof Date && valueB instanceof Date) {
		return valueA.getTime() - valueB.getTime();
	}
	// Fallback to string comparison
	return String(valueA).localeCompare(String(valueB));
}

/**
 * Options for sortRows function
 */
export interface SortRowsOptions<T> {
	/**
	 * Column configurations with optional custom comparators
	 */
	columns?: readonly ColumnSortConfig[];

	/**
	 * Function to get the ID from a row (defaults to row.id)
	 */
	getRowId?: (row: T) => unknown;
}

/**
 * Sort rows based on a sort model with support for multi-column sorting
 * and custom comparators.
 *
 * @param rows - Array of rows to sort
 * @param sortModel - Sort model specifying fields and directions
 * @param options - Optional configuration including column comparators
 * @returns New sorted array (does not mutate input)
 *
 * @example
 * ```ts
 * // Basic usage
 * const sorted = sortRows(users, [{ field: 'name', sort: 'asc' }]);
 *
 * // With custom comparator
 * const sorted = sortRows(users, [{ field: 'age', sort: 'desc' }], {
 *   columns: [{
 *     field: 'age',
 *     sortComparator: (a, b) => Number(a) - Number(b)
 *   }]
 * });
 * ```
 */
export function sortRows<T extends Record<string, unknown>>(
	rows: readonly T[],
	sortModel: SortModel,
	options: SortRowsOptions<T> = {},
): T[] {
	if (sortModel.length === 0) {
		return [...rows];
	}

	const { columns = [], getRowId = (row) => row.id } = options;

	// Create a map for quick column lookup
	const columnMap = new Map(columns.map((col) => [col.field, col]));

	const sortedRows = [...rows];

	sortedRows.sort((a, b) => {
		for (const sortItem of sortModel) {
			const { field, sort } = sortItem;
			if (!sort) continue;

			const column = columnMap.get(field);
			const valueA = a[field];
			const valueB = b[field];

			let result: number;

			if (column?.sortComparator) {
				result = column.sortComparator(
					valueA,
					valueB,
					{ id: getRowId(a), row: a },
					{ id: getRowId(b), row: b },
				);
			} else {
				result = defaultCompare(valueA, valueB);
			}

			if (result !== 0) {
				return sort === "asc" ? result : -result;
			}
		}
		return 0;
	});

	return sortedRows;
}
