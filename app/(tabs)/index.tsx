import {
	View,
	Text,
	StyleSheet,
	TouchableOpacity,
	FlatList,
	ActivityIndicator,
} from "react-native";
import { FontAwesome6 } from "@expo/vector-icons";
import { BluetoothStatus } from "@/components/BluetoothStatus";
import type { Scale } from "@/devices/types";
import { useEffect } from "react";
import { actions, store } from "@/services/bluetooth/store";
import { ConnectionState } from "@/types";
import { useSnapshot } from "valtio";

export default function ConnectScreen() {
	const { connectedDevice, state, scanning, devices } = useSnapshot(store);

	const renderDevice = ({ item: device }: { item: Scale }) => {
		const isConnected = connectedDevice?.id === device.id;
		const isConnecting = isConnected && state === ConnectionState.Connecting;

		return (
			<TouchableOpacity
				style={[styles.deviceButton, isConnected && styles.connectedDevice]}
				onPress={() =>
					isConnected
						? actions.disconnectDevice()
						: actions.connectToDevice(
								store.devices.find((val) => val.id === device.id)!,
							)
				}
				disabled={state === ConnectionState.Connecting && !isConnected}
			>
				<FontAwesome6
					name={device.iconName}
					size={24}
					color={isConnected ? "#007AFF" : "black"}
					style={styles.icon}
				/>
				<View style={styles.deviceInfo}>
					<Text style={styles.deviceName}>
						{device.name || "Unknown Device"}
					</Text>
					<Text style={styles.deviceStatus}>
						{device.type.charAt(0).toUpperCase() + device.type.slice(1)}
						{isConnected && " • Connected"}
					</Text>
				</View>
				{isConnecting ? (
					<ActivityIndicator color="#007AFF" />
				) : (
					<FontAwesome6
						name={isConnected ? "times-circle" : "chevron-right"}
						size={16}
						color={isConnected ? "#007AFF" : "gray"}
					/>
				)}
			</TouchableOpacity>
		);
	};

	useEffect(() => {
		actions.startScan();
	}, []);

	return (
		<View style={styles.container}>
			<BluetoothStatus />
			<View style={styles.header}>
				<Text style={styles.title}>Available Devices</Text>
				<TouchableOpacity
					onPress={scanning ? actions.stopScan : actions.startScan}
					style={styles.scanButton}
				>
					{scanning ? (
						<ActivityIndicator color="#007AFF" />
					) : (
						<Text style={styles.scanButtonText}>Scan</Text>
					)}
				</TouchableOpacity>
			</View>
			<FlatList
				data={devices}
				renderItem={renderDevice}
				keyExtractor={(item) => item.id}
				style={styles.list}
				contentContainerStyle={styles.listContent}
			/>
		</View>
	);
}

const styles = StyleSheet.create({
	container: {
		flex: 1,
		backgroundColor: "#fff",
	},
	header: {
		flexDirection: "row",
		justifyContent: "space-between",
		alignItems: "center",
		padding: 16,
		borderBottomWidth: StyleSheet.hairlineWidth,
		borderBottomColor: "#ccc",
	},
	title: {
		fontSize: 17,
		fontWeight: "600",
	},
	scanButton: {
		paddingHorizontal: 16,
		paddingVertical: 8,
		borderRadius: 16,
		backgroundColor: "#f0f0f0",
	},
	scanButtonText: {
		color: "#007AFF",
		fontWeight: "600",
	},
	list: {
		flex: 1,
	},
	listContent: {
		padding: 16,
	},
	deviceButton: {
		flexDirection: "row",
		alignItems: "center",
		padding: 16,
		backgroundColor: "#f5f5f5",
		borderRadius: 12,
		marginBottom: 12,
	},
	connectedDevice: {
		backgroundColor: "#e8f0fe",
		borderColor: "#007AFF",
		borderWidth: 1,
	},
	icon: {
		marginRight: 16,
	},
	deviceInfo: {
		flex: 1,
	},
	deviceName: {
		fontSize: 16,
		fontWeight: "600",
	},
	deviceStatus: {
		fontSize: 14,
		color: "gray",
		marginTop: 4,
	},
});
