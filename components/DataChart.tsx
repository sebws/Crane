import { measurementStore } from "@/services/bluetooth/measurementStore";
import { matchFont, useFont } from "@shopify/react-native-skia";
import type React from "react";
import { Platform, View, type StyleProp, type ViewStyle } from "react-native";
import { useSnapshot } from "valtio";
import { CartesianChart, Line } from "victory-native";

const fontFamily = Platform.select({ ios: "Helvetica", default: "sans-serif" });

const font = matchFont({
	fontFamily,
	fontSize: 14,
	fontStyle: "normal",
	fontWeight: "bold",
});

export default function DataChart({
	style,
}: React.ComponentProps<typeof View>) {
	const snap = useSnapshot(measurementStore);

	return (
		<View style={style}>
			<CartesianChart
				data={
					snap.measurementHistory.length > 0
						? snap.measurementHistory
						: [{ force: 0, timestamp: 0 }]
				}
				padding={10}
				xKey="timestamp"
				yKeys={["force"]}
				yAxis={[{ domain: [0], labelColor: "gray", font }]}
			>
				{({ points }) => (
					<Line points={points.force} color="black" strokeWidth={3} />
				)}
			</CartesianChart>
		</View>
	);
}
