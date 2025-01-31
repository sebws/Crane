import DataChart from "@/components/DataChart";
import { measurementStore } from "@/services/bluetooth/measurementStore";
import { store, actions } from "@/services/bluetooth/store";
import React, { useEffect } from "react";
import { View, StyleSheet, Text } from "react-native";
import { useSnapshot } from "valtio";

export default function Tab() {
	const { connectedDevice } = useSnapshot(store);
	const { currentForce } = useSnapshot(measurementStore);

	useEffect(() => {
		if (connectedDevice) {
			actions.startMeasurement();
		}
		return () => {
			actions.stopMeasurement();
		};
	}, [connectedDevice]);

	return (
		<View style={styles.container}>
			<View style={{ flex: 1, justifyContent: "center" }}>
				<Text
					style={{
						width: 100,
						fontSize: 30,
						fontWeight: 700,
						fontVariant: ["tabular-nums"],
						textAlign: "right",
					}}
				>
					{(currentForce ?? 0).toFixed(0)} kg
				</Text>
			</View>
			<DataChart style={{ flex: 2, height: "100%", width: "100%" }} />
		</View>
	);
}

const styles = StyleSheet.create({
	container: {
		flex: 1,
		display: "flex",
		justifyContent: "center",
		alignItems: "center",
		padding: 16,
	},
});
