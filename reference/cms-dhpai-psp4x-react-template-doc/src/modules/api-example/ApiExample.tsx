import {
	DataEnquiry,
	DataEnquiryAction,
	DataEnquiryFilter,
	DataEnquiryFilterCriteria,
	DataTable,
	DataTableColumn,
	DialogActionBar,
	FormLabel,
	RadioButtonGroup,
	TextField,
	Vertical,
} from "@cmschassis/react-ui";
import { Close as CloseIcon, ExpandMore } from "@mui/icons-material";
import {
	Autocomplete,
	AutocompleteRenderInputParams,
	Box,
	Button,
	CircularProgress,
	Dialog,
	DialogContent,
	DialogTitle,
	Divider,
	Grid,
	IconButton,
	TextField as MuiTextField,
	Paper,
	Typography,
} from "@mui/material";
import {
	QueryClient,
	QueryClientProvider,
	useMutation,
	useQuery,
	useQueryClient,
} from "@tanstack/react-query";
import React, { useEffect, useState } from "react";
import cms from "../../cms-plugin/cms-api-provider";
import { mySvcUrl } from "../../constant";

type ApiExampleViewProps = {
	viewId: string;
};

type Product = {
	id?: number;
	name: string;
	description: string;
	price: number;
	type: "HARDWARE" | "SOFTWARE" | "SERVICE" | "OTHER";
	createdAt?: string;
	updatedAt?: string;
	createBy?: string;
	updateBy?: string;
	version?: number;
};

type DropDownListProps = {
	label: string;
	defaultValue: string;
	options: string[];
	onChange: (newValue: string) => void;
	width?: number;
};

const DropDownList = ({
	label,
	defaultValue,
	options,
	onChange,
	width,
}: DropDownListProps) => {
	return (
		<Vertical spacing="related">
			<FormLabel label={label} />
			<Autocomplete
				id={`combo-box-${label}`}
				options={options}
				getOptionLabel={(option: string) => option}
				filterOptions={(options: string[], params: { inputValue: string }) => {
					const inputStrLowered = params.inputValue.toLowerCase();
					const filtered = options.filter((option: string) =>
						option.toLowerCase().includes(inputStrLowered),
					);
					return filtered;
				}}
				value={defaultValue}
				popupIcon={<ExpandMore />}
				renderInput={(params: AutocompleteRenderInputParams) => (
					<MuiTextField {...params} />
				)}
				onChange={(_e: React.SyntheticEvent, value: string | null) =>
					onChange(value ?? "")
				}
				sx={{ width }}
			/>
		</Vertical>
	);
};

type RadioTypeProps = {
	value: string;
	label: string;
	options: string[];
	onChange: (value: string) => void;
};

const RadioGroup = ({ value, label, options, onChange }: RadioTypeProps) => {
	return (
		<RadioButtonGroup
			direction="row"
			label={label}
			value={value}
			onChange={(newValue: string) => onChange(newValue)}
			options={options}
			optionValue={(option: string) => option}
			renderOption={(option: string) => option}
		/>
	);
};

type ProductDialogProps = {
	open: boolean;
	product?: Product;
	onSave: (product: Product) => void;
	onCancel: () => void;
	onClose: () => void;
};

function ProductDialog({
	open,
	product,
	onSave,
	onCancel,
	onClose,
}: ProductDialogProps) {
	const [dialogOpen, setDialogOpen] = useState(open);
	const [name, setName] = useState(product?.name ?? "");
	const [description, setDescription] = useState(product?.description ?? "");
	const [price, setPrice] = useState(product?.price?.toString() ?? "");
	const [type, setType] = useState<Product["type"]>(
		product?.type ?? "HARDWARE",
	);

	const handleClose = () => {
		setDialogOpen(false);
		onClose();
	};

	const handlePriceChange = (value: string) => {
		// Allow empty string, numbers, and decimal point
		if (value === "" || /^\d*\.?\d*$/.test(value)) {
			setPrice(value);
		}
	};

	const handleSave = () => {
		const productData: Product = {
			name,
			description,
			price: Number(price),
			type,
			...(product?.id && { id: product.id, version: product.version }),
		};
		onSave(productData);
		// Don't close here - let the parent component close after successful mutation
	};

	return (
		<Dialog open={dialogOpen} onClose={handleClose} fullWidth maxWidth="md">
			<DialogTitle fontSize={18}>
				{"Add Product"}
				<IconButton
					aria-label="close"
					onClick={handleClose}
					sx={{
						position: "absolute",
						right: 8,
						top: 8,
					}}
				>
					<CloseIcon />
				</IconButton>
			</DialogTitle>
			<DialogContent>
				<Box sx={{ display: "flex", flexDirection: "column", gap: 2, pt: 2 }}>
					<TextField
						size="small"
						label="Product Name"
						value={name}
						onChange={setName}
					/>
					<TextField
						size="small"
						label="Description"
						value={description}
						onChange={setDescription}
					/>
					<TextField
						size="small"
						label="Price"
						value={price}
						onChange={handlePriceChange}
						placeholder="e.g. 99.99"
					/>
					<DropDownList
						label="Type"
						defaultValue={type}
						options={["HARDWARE", "SOFTWARE", "SERVICE", "OTHER"]}
						onChange={(value: string) => setType(value as Product["type"])}
						width={300}
					/>
				</Box>
			</DialogContent>

			<Paper sx={{ position: "sticky", bottom: 0 }} component="footer">
				<DialogActionBar variant="informative">
					<Grid container spacing={10}>
						<Grid item>
							<Button onClick={onCancel} size="small" variant="outlinedInverse">
								Cancel
							</Button>
						</Grid>
						<Grid item>
							<Button
								onClick={handleSave}
								size="small"
								variant="containedInverse"
							>
								Save
							</Button>
						</Grid>
					</Grid>
				</DialogActionBar>
			</Paper>
		</Dialog>
	);
}

const ApiExampleContent = ({ viewId }: ApiExampleViewProps) => {
	const queryClient = useQueryClient();
	const shellVersion = cms.api.session?.get().environment.shell;

	const accessToken = (() => {
		if (shellVersion === "MX") {
			return cms.api.auth?.get().accessToken;
		}
		return undefined;
	})();

	const [products, setProducts] = useState<Product[]>([]);
	const [filteredProducts, setFilteredProducts] = useState<Product[]>([]);
	const [addDialogOpen, setAddDialogOpen] = useState(false);

	// Filter states
	const [productName, setProductName] = useState("");
	const [productType, setProductType] = useState("All");

	// Helper function to close dialogs
	const handleClose = () => {
		setAddDialogOpen(false);
	};

	// Fetch products (GET)
	const query = useQuery({
		queryKey: ["products"],
		queryFn: async () => {
			const headers: Record<string, string> = {
				Accept: "application/json",
			};

			if (accessToken) {
				headers.Authorization = `Bearer ${accessToken}`;
			}

			if (!mySvcUrl) {
				throw new Error("API service URL is not defined.");
			}

			const response = await fetch(`${mySvcUrl}/v1/product`, {
				method: "GET",
				headers,
				credentials: "include",
			});

			if (!response.ok) {
				throw new Error("Failed to fetch products");
			}

			return response.json();
		},
	});

	useEffect(() => {
		if (query.data) {
			setProducts(query.data);
			setFilteredProducts(query.data);
		}
	}, [query.data]);

	// Create product (POST)
	const createMutation = useMutation({
		mutationFn: async (newProduct: Product) => {
			const headers: Record<string, string> = {
				"Content-Type": "application/json",
				Accept: "application/json",
			};

			if (accessToken) {
				headers.Authorization = `Bearer ${accessToken}`;
			}

			const response = await fetch(`${mySvcUrl}/v1/product`, {
				method: "POST",
				headers,
				credentials: "include",
				body: JSON.stringify({
					name: newProduct.name,
					description: newProduct.description,
					price: newProduct.price,
					type: newProduct.type,
				}),
			});

			if (!response.ok) {
				throw new Error("Failed to create product");
			}

			return response.json();
		},
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: ["products"] });
			handleClose();
		},
	});

	// Filter handlers
	const handleFilter = () => {
		console.log("Filter button clicked");
		const filterName = (row: Product) =>
			productName === "" ||
			row.name.toLowerCase().includes(productName.toLowerCase());
		const filterType = (row: Product) =>
			productType === "All" || productType === row.type;

		const result = products.filter(filterName).filter(filterType);
		setFilteredProducts(result);
	};

	const handleClear = () => {
		console.log("Clear button clicked");
		setProductName("");
		setProductType("All");
		setFilteredProducts(products);
	};

	const handleAdd = () => {
		setAddDialogOpen(true);
	};

	const handleSaveProduct = (product: Product) => {
		createMutation.mutate(product);
	};

	const columns: DataTableColumn<Product>[] = [
		{
			field: "name",
			title: "Product Name",
			sortable: true,
			width: "300px",
		},
		{
			field: "description",
			title: "Description",
			sortable: true,
			width: "300px",
		},
		{
			field: "price",
			title: "Price",
			sortable: true,
			width: "100px",
			render: (row) => `$${row.price.toFixed(2)}`,
		},
		{
			field: "type",
			title: "Type",
			sortable: true,
			width: "120px",
		},
	];

	if (query.isLoading) {
		return (
			<Box display="flex" justifyContent="center" p={3}>
				<CircularProgress />
			</Box>
		);
	}

	if (query.error) {
		return (
			<Box p={3}>
				<Typography color="error">
					Error:{" "}
					{query.error instanceof Error
						? query.error.message
						: "An error occurred"}
				</Typography>
			</Box>
		);
	}

	const filter = (
		<DataEnquiryFilter onFilter={handleFilter} onClear={handleClear}>
			<DataEnquiryFilterCriteria>
				<TextField
					value={productName}
					placeholder="Search by product name"
					label="Product Name"
					onChange={setProductName}
					fullWidth={false}
					sx={{ width: 400 }}
				/>
				<Divider orientation="vertical" />
				<RadioGroup
					value={productType}
					label="Product Type"
					options={["All", "HARDWARE", "SOFTWARE", "SERVICE", "OTHER"]}
					onChange={setProductType}
				/>
			</DataEnquiryFilterCriteria>
		</DataEnquiryFilter>
	);

	const action = (
		<DataEnquiryAction
			size="small"
			primaryAction={{
				label: "Add",
				onClick: handleAdd,
			}}
		/>
	);

	return (
		<Box
			sx={{
				backgroundColor: "greyscale.white",
				display: "flex",
				flexDirection: "column",
				height: "100%",
			}}
		>
			<Typography
				sx={{
					paddingTop: 15,
					paddingLeft: 12,
					paddingRight: 12,
					paddingBottom: 20,
					fontWeight: 700,
					fontSize: 21,
					color: "greyscale.grey3.main",
				}}
			>
				{viewId}: Product Management
			</Typography>

			<DataEnquiry filter={filter} action={action}>
				<DataTable columns={columns} rows={filteredProducts} showNumOfRecords />
			</DataEnquiry>

			{addDialogOpen && (
				<ProductDialog
					open={addDialogOpen}
					onSave={handleSaveProduct}
					onCancel={handleClose}
					onClose={handleClose}
				/>
			)}
		</Box>
	);
};

export const ApiExample = (props: ApiExampleViewProps) => {
	const queryClient = new QueryClient();

	return (
		<QueryClientProvider client={queryClient}>
			<ApiExampleContent {...props} />
		</QueryClientProvider>
	);
};
