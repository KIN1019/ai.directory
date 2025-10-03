# `<DataTable />`

`DataTable` is the core grid component shipped by **@cmschassis/react-ui**.  
It renders an array of plain objects as a _virtualised_, _sortable_, _paginated_ table and exposes hooks for editing, selection, expansion and server-side integration.

> MUI primitives (e.g. `Stack`, `Tooltip`, `Button`) are **not** covered here.

---

## Props

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `rows` | `T[]` | ✅ | Source data. |
| `columns` | `DataTableColumn<T>[]` | ✅ | Column schema (see next section). |
| `height` | `string \| number` |  | Fixed viewport height; enables automatic virtual scrolling. |
| `rowHeight` | `number` |  | Overrides default row height. |
| `childTableHeight` | `number` |  | Row height used for expanded (child) content. |
| `editable` | `boolean` |  | Enables in-place cell editing. |
| `deletable` | `boolean` |  | Allows rows to be _marked for deletion_. |
| `showPagination` | `boolean` |  | Turns on built-in **client** pagination UI. |
| `showNumOfRecords` | `boolean` |  | Toggles the "X-Y of Z records" text in the pagination footer. |
| `clientPagination` | `{ rowsPerPage?: number[] }` |  | Custom rows-per-page options. |
| `manualPagination` | `manualPaginationType` |  | Bridge object for **server** pagination. |
| `sortOrders` | `OrderBy<T>[]` |  | Controlled sort state. |
| `onChangeSortOrders` | `(orders:OrderBy<T>[]) => void` |  | Callback when header sort changes while you control sort externally. |
| `selectedRowIndexList` | `number[]` |  | Controlled selection (indexes refer to the original `rows` array). |
| `enableMultiRowSelection` | `boolean` |  | Toggle single vs. multi-select behaviour. |
| `expandRowStates` | `ManualExpandProps` |  | Programmatic expand / collapse. |
| `renderExpandedRow` | `(row:T, selected:boolean, size:DataTableSizeType) => VNode` |  | Custom child row content. Typically returns `<ExpandedRow />`. |
| `onRowClick` | `(rowIdx:number, row:T) => void` |  | Fired on single-click. |
| `onRowDoubleClick` | `(rowIdx:number, row:T) => void` |  | Fired on double-click. |
| `onRowContextMenu` | `(rowIdx:number, row:T, e:MouseEvent) => void` |  | Fired on right-click. |
| `onRowStateChangeListener` | `(rowIdx:number, row:T, state:RowState, e?:MouseEvent) => void` |  | Notified when a row expands/collapses or toggles selection. |
| `onAfterRowChange` | `(rowIdx:number, row:T, status:RowChangeStatus) => void` |  | Called after add / edit / mark-delete / undo-delete. |
| `onAfterRowSelectionChange` | `(selected:T[]) => void` |  | Emits current selection when the table manages selection itself. |
| `onViewChange` | `(view: ViewType[]) => void` | | Callback when the virtual viewport's rendered rows change due to scrolling. |
| `renderValidationMessage` | `(row:T) => DataTableValidationMessage[]` |  | Return row-level warnings / errors shown during edit mode. |

---

## Column Definition — `DataTableColumn<T>`

```ts
interface DataTableColumn<T = any> {
  field: keyof T | ((row: T) => any) | undefined
  title: string | (() => VNode)
  render?: (
    row: T,
    rowIndex: number,
    viewIndex: number,
    editable: boolean,
    updateRowData: (rowIdx: number, newRow: T, status: RowChangeStatus) => void,
    markAsDelete: boolean
  ) => VNode
  width?: string | number
  sortable?: boolean
  customSort?: (a: T, b: T) => number
  freezeColumn?: boolean
  tableCellStyle?: CSSProperties
  sortController?: { // Used for server-side single column sort
    isSorted: boolean
    direction: 'asc' | 'desc' | undefined
    onClickSort: (nextDirection: 'asc' | 'desc' | undefined) => void
  }
}
```

---

## Imperative API

Attach a `ref` and type it as **`ScrollableTable`**:

```ts
interface ScrollableTable {
  /** Scroll until the given row index is visible */
  scrollTo(rowIndex: number): void

  /** Reset scroll position to the top/left */
  scrollToOrigin(): void
}

// usage
const tableRef = ref<ScrollableTable | null>(null)
<DataTable ref={tableRef} rows={rows} columns={cols} height="400px" />
```

---

## Helper Types & Components

### `ExpandedRow` Component

A utility component typically returned by the `renderExpandedRow` prop to display a list of key-value pairs in the expanded area of a row.

**Props:**

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `dataList` | `{ title: string; value: any; width?: string }[]` | ✅ | Array of items to display. Each item has a title, value, and optional width. |
| `selected` | `boolean` | ✅ | Indicates if the parent row is currently selected (affects styling). |
| `size` | `DataTableSizeType` | ✅ | The current size context of the DataTable (e.g., 'small', 'medium', 'large'), used for styling. |

### Other Helper Types

```ts
type OrderBy<T> = { field: keyof T | ((row:T)=>any); direction: 'asc' | 'desc' }

enum RowChangeStatus {
  ADD,
  EDIT,
  MARK_DELETE,
  UNDO_DELETE
}

interface DataTableValidationMessage {
  variant: 'error' | 'warning' | 'info'
  message: string
}

interface ManualExpandProps {
  expandStates: { index: number; isExpand: boolean }[]
  key: number  // increment to trigger a one-off expand action
}

interface manualPaginationType {
  pageIndex: number
  pageSize: number
  pageCount: number
  recordCount: number
  rowsPerPage?: number[]
  onPageIndexChange(index: number): void
  onPageSizeChange(size: number): void
}

type RowState = 'EXPANDED' | 'COLLAPSED' | 'SELECTED' | 'UNSELECTED'

// Describes a row currently rendered in the virtual viewport
interface ViewType {
  rowIndex: number // Original index in the `rows` prop
  // ... other properties related to virtual rendering offset/position
}

// Size options passed to renderExpandedRow and ExpandedRow
type DataTableSizeType = 'small' | 'medium' | 'large' // Or other relevant sizes
```

---

## Quick Example

```tsx
      <DataTable
        height="500px"
  rows={orders}
  columns={[
    { field: 'id', title: 'ID', freezeColumn: true },
    { field: 'orderNum', title: 'Order #' },
    {
      field: 'price',
      title: 'Price',
      render: ({ price }) => `HKD ${price}`,
      customSort: (a, b) => (a.price ?? 0) - (b.price ?? 0)
    }
  ]}
        showPagination
  clientPagination={{ rowsPerPage: [10, 25, 50] }}
  onRowDoubleClick={(idx, row) => console.log('double-clicked', idx, row)}
  renderExpandedRow={(row, selected, size) => {
    if (row.id % 2 === 0) return null // Example: only expand odd rows
    const details = [
      { title: "Order Date", value: row.orderDate },
      { title: "Full Remark", value: `${row.remark?.user}: ${row.remark?.text}` }
    ];
    return <ExpandedRow dataList={details} selected={selected} size={size} />
  }}
/>
```
