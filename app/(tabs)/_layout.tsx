import { FontAwesome6 } from "@expo/vector-icons";
import { Tabs } from "expo-router";

export default function TabLayout() {
	return (
		<Tabs screenOptions={{ tabBarActiveTintColor: "black" }}>
			<Tabs.Screen
				name="live"
				options={{
					title: "Live",
					tabBarIcon: ({ color }) => (
						<FontAwesome6 size={28} name="chart-line" color={color} />
					),
				}}
			/>
			<Tabs.Screen
				name="index"
				options={{
					title: "Connect",
					tabBarIcon: ({ color }) => (
						<FontAwesome6 size={28} name="wifi" color={color} />
					),
				}}
			/>
			<Tabs.Screen
				name="repeaters"
				options={{
					title: "Repeaters",
					tabBarIcon: ({ color }) => (
						<FontAwesome6 size={28} name="repeat" color={color} />
					),
				}}
			/>
		</Tabs>
	);
}
