import LockIcon from "@mui/icons-material/Lock";
import { pspColors } from "../../theme/pspTheme";

interface LockIconCellProps {
	locked: boolean;
}

/** Lock icon for patient rows */
export const LockIconCell = ({ locked }: LockIconCellProps) =>
	locked ? <LockIcon sx={{ color: pspColors.lockIcon, fontSize: 12 }} /> : null;

/** Lock icon for column header */
export const LockHeaderIcon = () => (
	<LockIcon sx={{ color: pspColors.lockIconHeader, fontSize: 12 }} />
);

// Re-export for backward compatibility
export { LockIconCell as LockIcon };
