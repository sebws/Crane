import { proxy } from "valtio";

interface MeasurementState {
	currentForce: number | null;
	measurementHistory: { timestamp: number; force: number }[];
}

export const measurementStore = proxy<MeasurementState>({
	currentForce: null,
	measurementHistory: [],
});

export const measurementActions = {
	addMeasurement(force: number) {
		measurementStore.currentForce = force;
		measurementStore.measurementHistory.push({
			timestamp: Date.now(),
			force,
		});

		// Keep history length manageable
		if (measurementStore.measurementHistory.length > 100) {
			measurementStore.measurementHistory =
				measurementStore.measurementHistory.slice(-100);
		}
	},

	clear() {
		measurementStore.currentForce = null;
		measurementStore.measurementHistory = [];
	},
};
