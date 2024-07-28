package com.example.electronicscale.ui.home;

import android.annotation.TargetApi;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothManager;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanRecord;
import android.bluetooth.le.ScanResult;
import android.bluetooth.le.ScanSettings;
import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.util.Log;
import android.widget.Toast;

import com.example.electronicscale.R;
import com.example.electronicscale.RegisterActivity;
import com.example.electronicscale.domain.WhDevice;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class ScaleWatcher {
    private String Tag = "ScaleWatcher";
    public static ArrayList<String> bluetoothNameList = new ArrayList<String>();

    public static List<String> targetDeviceNames = new ArrayList<>();

    //对应数据在 厂家专有数据 里的偏移量
    public int WEIGHT_OFFSET = 10;   //重量偏移值，若有变化，参见秤硬件文档

    public int STABLE_OFFSET = 14;  //稳定状态标志的偏移量

    //厂家专有数据里的厂家id，固定为256，若有变化，参见秤硬件文档
    public static int MANUFACTURER_ID = 256;

    //目标设备的名称，可根据自己目标设备的不同去修改该名称来完成连接
    public static String mTargetDeviceName = "";

    // 标识符
    public static String IDENTIFIER = "W";

    private Handler handler = new Handler();

    /**
     * id 开始数
     */
    public static int idStart = 13;

    /**
     * 偏移数
     */
    public static int idEnd = 8;

    public static boolean isContent = true;

    private final static int SCAN_STOPPED = 1;
    private final static int SCAN_STARTED = 2;
    private final static int SCAN_STOPPING = 3;

    private static int scanState  = SCAN_STOPPED;
    private static long lastStartScanTimeMillis = 0;

    //--
    private BluetoothManager mBluetoothManager;
    private BluetoothAdapter mBluetoothAdapter;
    private BluetoothLeScanner mBluetoothLeScanner;
    private List<BluetoothGattService> mServiceList;
    private ScanCallback mScanCallback;

    //
    private ScaleListener scaleListener;

    // 转码标志 0 十进制 1 asicc
    public static int codeFlag = 0;


    private static ScaleWatcher scaleWatcherInstance = null;

    //private WeightListener weightListener = null;
    public class WeightRecord {
        public double weight;   //重量值，单位0.01kg
        public int stable;      //稳定标志
        public int unit;        //重量单位 1：kg,  2：LB, 3：ST, 4：斤
    }

    public interface ScaleListener {
        void OnWeightUpdate(WeightRecord wr);
        void OnTargetDeviceNamesUpdate(List<String> targetDeviceNames);
    }


    public ScaleWatcher(Context context, ScaleListener scaleListener, int manufactureId) {
        this.scaleListener = scaleListener;
        mScanCallback = new LeScanCallback();
        MANUFACTURER_ID = manufactureId;
        initBluetooth(context);
    }

    /**
     * enable bluetooth
     */
    private void initBluetooth(Context context) {
        //get Bluetooth service
        mBluetoothManager = (BluetoothManager) context.getApplicationContext().getSystemService(Context.BLUETOOTH_SERVICE);
        //get Bluetooth Adapter
        mBluetoothAdapter = mBluetoothManager.getAdapter();
        if (mBluetoothAdapter == null) {//platform not support bluetooth
            Log.d(Tag, "Bluetooth is not support");
        }
        else{
            int status = mBluetoothAdapter.getState();
            //bluetooth is disabled
            if (status == BluetoothAdapter.STATE_OFF) {
                // enable bluetooth
                mBluetoothAdapter.enable();
            }
        }

        ListEquipmentActivity.dataArray = targetDeviceNames;
        //Android 4.3以上，Android 5.0以下
        //mBluetoothAdapter.startLeScan(BluetoothAdapter.LeScanCallback);
        //Android 5.0以上，扫描的结果在mScanCallback中进行处理
        mBluetoothLeScanner = mBluetoothAdapter.getBluetoothLeScanner();
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    public void startWatcher() {
//        //谷歌只允许 每 2分钟调用4次 startScan， 否则会失败。所以。。。
//        if(scanState == SCAN_STOPPED || scanState == SCAN_STOPPING) {
//            System.out.println("扫描： startScan");
//            mBluetoothLeScanner.startScan(null, createScanSetting(), mScanCallback);
//
//            scanState = SCAN_STARTED;
//            lastStartScanTimeMillis = System.currentTimeMillis();
//        }
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    public void stopWatcher() {
        long currentTimeMillis = System.currentTimeMillis();
        System.out.println("扫描： stopWatcher: currentTimeMillis: " + currentTimeMillis +
                ", lastStartScanTimeMillis" + lastStartScanTimeMillis);

        switch(scanState) {
            case SCAN_STOPPED:
                break;

            case SCAN_STARTED:
                if( currentTimeMillis - lastStartScanTimeMillis > 5000) {
                    System.out.println("扫描： stopWatcher");
                    mBluetoothLeScanner.stopScan(mScanCallback);
                    scanState = SCAN_STOPPED;
                } else {
                    handler.postDelayed(new Runnable() {
                        @Override
                        public void run() {
                            if (scanState == SCAN_STOPPING) {
                                System.out.println("扫描：delayed stopWatcher");
                                mBluetoothLeScanner.stopScan(mScanCallback);
                                scanState = SCAN_STOPPED;
                            }
                        }
                    }, 5000);
                    scanState = SCAN_STOPPING;
                }
                break;
            case SCAN_STOPPING:
                if (currentTimeMillis - lastStartScanTimeMillis > 1000 * 1000) {
                    System.out.println("扫描： stopWatcher");
                    mBluetoothLeScanner.stopScan(mScanCallback);
                    scanState = SCAN_STOPPED;
                }
                break;
        }

    }

    public ScanSettings createScanSetting() {
        ScanSettings.Builder builder = new ScanSettings.Builder();
        builder.setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY);
        //builder.setReportDelay(100);//设置延迟返回时间
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            builder.setCallbackType(ScanSettings.CALLBACK_TYPE_ALL_MATCHES);
        }
        return builder.build();
    }

    /**
     * LE设备扫描结果返回
     */
    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    private class LeScanCallback  extends ScanCallback{

        /**
         * 扫描结果的回调，每次扫描到一个设备，就调用一次。
         * @param callbackType
         * @param result
         */
        @Override
        public void onScanResult(int callbackType, ScanResult result) {
            if(result == null || "".equals(result.getDevice().getName())) {
                return;
            }

            for (String name : bluetoothNameList) {
                System.out.println("扫描：" + name);
            }

            //忽略不认识的蓝牙
            if( result.getDevice().getName() == null || !bluetoothNameList.contains(result.getDevice().getName()) ) {
                //System.out.println("扫描到 不认识的蓝牙 " + result.getDevice().getName());
                return;
            }
            System.out.println("扫描到 认识的蓝牙：" + result.getDevice().getName());

            //将扫描的的认识的蓝牙设备添加到设备选择列表

            ScanRecord rawScanRecord = result.getScanRecord();
            byte[] rawBytes = rawScanRecord.getBytes();
            int manuFactureId;

            // 通过设备信息拿到的 codeFlag 通过是0 用十进制解析ID
            if (codeFlag == 0) {
                manuFactureId =  ((rawBytes[idStart] & 0xff) << idEnd) + (rawBytes[idStart - 1] & 0xff);
            }
            // 如果是其他用的 则用asill码拼接
            else {
                manuFactureId = SumStrAscii(((rawBytes[idStart] & 0xff) << idEnd) + (rawBytes[idStart - 1] & 0xff) + "");
            }

            System.out.println("扫描到机身id：" + manuFactureId);

            for(String dname: targetDeviceNames) {
                System.out.println("扫描： 现有设备： " + dname);
            }

            if(result.getDevice().getName() != null && !targetDeviceNames.contains(result.getDevice().getName() + IDENTIFIER + manuFactureId) ){
                targetDeviceNames.add(result.getDevice().getName() + ScaleWatcher.IDENTIFIER + manuFactureId);
                if(ScaleWatcher.this.scaleListener != null) {
                    ScaleWatcher.this.scaleListener.OnTargetDeviceNamesUpdate(targetDeviceNames);
                }
            }

            //ListEquipmentActivity.dataArray = targetDeviceNames;

            //扫描指定机身id 的数据获得称重数据

            System.out.println("扫描： MANUFACTURER_ID： " + MANUFACTURER_ID + ", mTargetDeviceName: " + mTargetDeviceName);

            ScanRecord  sr= result.getScanRecord();
            byte[] bytes = sr.getManufacturerSpecificData(MANUFACTURER_ID);

            // 如果广播数据中没有到当前id的数据，则忽略
            if (bytes == null || sr.getDeviceName() == null) {
                return;
            }

            if(mTargetDeviceName != null && mTargetDeviceName.equals(sr.getDeviceName() + ScaleWatcher.IDENTIFIER + manuFactureId)) {
                int weight = ( (bytes[WEIGHT_OFFSET] & 0xff) << 8) | bytes[WEIGHT_OFFSET + 1] & 0xff;
                int stable = (bytes[STABLE_OFFSET] & 0xf0) >> 4;
                int unit = bytes[STABLE_OFFSET] & 0x0f;
                if(ScaleWatcher.this.scaleListener != null) {
                    WeightRecord weightRecord = new WeightRecord();
                    weightRecord.weight = weight;
                    weightRecord.stable = stable;
                    weightRecord.unit = unit;
                    System.out.println("扫描： OnWeightUpdate: weight: " + weightRecord.weight);
                    ScaleWatcher.this.scaleListener.OnWeightUpdate(weightRecord);
                }
            }
        }

    }

    /**
     * gatt连接结果的返回
     */
    private BluetoothGattCallback mGattCallback = new BluetoothGattCallback() {

        /**
         * Callback indicating when GATT client has connected/disconnected to/from a remote GATT server
         *
         * @param gatt 返回连接建立的gatt对象
         * @param status 返回的是此次gatt操作的结果，成功了返回0
         * @param newState 每次client连接或断开连接状态变化，STATE_CONNECTED 0，STATE_CONNECTING 1,STATE_DISCONNECTED 2,STATE_DISCONNECTING 3
         */
        @Override
        public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
            Log.d(Tag, "onConnectionStateChange status:" + status + "  newState:" + newState);
            if (status == 0) {
                gatt.discoverServices();
            }
        }

        /**
         * Callback invoked when the list of remote services, characteristics and descriptors for the remote device have been updated, ie new services have been discovered.
         *
         * @param gatt 返回的是本次连接的gatt对象
         * @param status
         */
        @Override
        public void onServicesDiscovered(BluetoothGatt gatt, int status) {
            Log.d(Tag, "onServicesDiscovered status" + status);
            mServiceList = gatt.getServices();
            if (mServiceList != null) {
                System.out.println(mServiceList);
                System.out.println("Services num:" + mServiceList.size());
            }

            for (BluetoothGattService service : mServiceList){
                List<BluetoothGattCharacteristic> characteristics = service.getCharacteristics();
                System.out.println("扫描到Service：" + service.getUuid());

                for (BluetoothGattCharacteristic characteristic : characteristics) {
                    System.out.println("characteristic: " + characteristic.getUuid() );
                }
            }
        }

        /**
         * Callback triggered as a result of a remote characteristic notification.
         *
         * @param gatt
         * @param characteristic
         */
        @Override
        public void onCharacteristicChanged(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic) {
            Log.d(Tag, "onCharacteristicChanged");
        }

        /**
         * Callback indicating the result of a characteristic write operation.
         *
         * @param gatt
         * @param characteristic
         * @param status
         */
        @Override
        public void onCharacteristicWrite(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
            Log.d(Tag, "onCharacteristicWrite");
        }

        /**
         *Callback reporting the result of a characteristic read operation.
         *
         * @param gatt
         * @param characteristic
         * @param status
         */
        @Override
        public void onCharacteristicRead(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
            Log.d(Tag, "onCharacteristicRead");
        }

        /**
         * Callback indicating the result of a descriptor write operation.
         *
         * @param gatt
         * @param descriptor
         * @param status
         */
        @Override
        public void onDescriptorWrite(BluetoothGatt gatt, BluetoothGattDescriptor descriptor, int status) {
            Log.d(Tag, "onDescriptorWrite");
        }
    };



    /**
     * 十进制转Ascii码 累加
     *
     * @param str
     * @return
     */
    public static int SumStrAscii(String str){
        byte[] bytestr = str.getBytes();
        int sum = 0;
        for(int i=0;i<bytestr.length;i++){
            sum += bytestr[i];
        }
        return sum;
    }

}
