import { View, Text, StyleSheet } from "react-native";
import { FontAwesome6 } from "@expo/vector-icons";
import { store } from "@/services/bluetooth/store";
import { ConnectionState } from "@/types";
import { useSnapshot } from "valtio";

export function BluetoothStatus() {
	const { state } = useSnapshot(store);
	const isEnabled = state !== ConnectionState.Off;

	return (
		<View style={styles.container}>
			<FontAwesome6
				name={isEnabled ? "bluetooth" : "bluetooth-b"}
				size={20}
				color={isEnabled ? "#007AFF" : "#FF3B30"}
			/>
			<Text style={[styles.text, { color: isEnabled ? "#007AFF" : "#FF3B30" }]}>
				{isEnabled ? "Bluetooth On" : "Bluetooth Off"}
			</Text>
		</View>
	);
}

const styles = StyleSheet.create({
	container: {
		flexDirection: "row",
		alignItems: "center",
		padding: 16,
		backgroundColor: "#f8f8f8",
		borderBottomWidth: StyleSheet.hairlineWidth,
		borderBottomColor: "#ccc",
	},
	text: {
		marginLeft: 8,
		fontSize: 16,
		fontWeight: "500",
	},
});
