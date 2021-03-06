﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Microsoft.Azure.Devices;
using System.Text;
using System.Threading.Tasks;

namespace ConnectTheDotsWebSite.Helpers
{
    public static class IoTHubHelper
    {
        public static void SendMessage(string deviceId, string messageText)
        {
            var message = new Message(Encoding.ASCII.GetBytes(messageText));
            var serviceClient = ServiceClient.CreateFromConnectionString(Microsoft.Azure.CloudConfigurationManager.GetSetting("Azure.IoT.IoTHub.ConnectionString"), TransportType.Amqp);
            if (serviceClient!=null) serviceClient.SendAsync(deviceId, message).Wait();
        }

        public enum DeleteDeviceResult
        {
            Success,
            DeviceNotRegistered,
            Error
        }

        public static DeleteDeviceResult DeleteDevice(string deviceId)
        {
            var manager = RegistryManager.CreateFromConnectionString(Microsoft.Azure.CloudConfigurationManager.GetSetting("Azure.IoT.IoTHub.ConnectionString"));
            if (manager != null)
            {
                // Check if device exists
                Device device = manager.GetDeviceAsync(deviceId).Result;
                if (device == null)
                    return DeleteDeviceResult.DeviceNotRegistered;
                else
                {
                    manager.RemoveDeviceAsync(deviceId);
                    return DeleteDeviceResult.Success;
                }
            }
            return DeleteDeviceResult.Error;
        }

        public enum AddDeviceResult
        {
            Success,
            DeviceAlreadyExists,
            Error
        }

        public static AddDeviceResult AddDevice(string deviceId)
        {
            var manager = RegistryManager.CreateFromConnectionString(Microsoft.Azure.CloudConfigurationManager.GetSetting("Azure.IoT.IoTHub.ConnectionString"));
            if (manager != null)
            {
                // Check if device already exists
                Device device = manager.GetDeviceAsync(deviceId).Result;
                if (device != null)
                    return AddDeviceResult.DeviceAlreadyExists;
                else
                {
                    device = manager.AddDeviceAsync(new Device(deviceId)).Result;
                    return (device == null) ? AddDeviceResult.Error : AddDeviceResult.Success;
                }
            }
            return AddDeviceResult.Error;
        }


        public static List<IDictionary<string, object>> ListDevices(int count)
        {
            IEnumerable<Device> devices;
            List<IDictionary<string, object>> result = null;

            var iotHubConnectionString = Microsoft.Azure.CloudConfigurationManager.GetSetting("Azure.IoT.IoTHub.ConnectionString");

            var manager = RegistryManager.CreateFromConnectionString(iotHubConnectionString);

            if (manager != null)
            {
                try
                {
                    devices = manager.GetDevicesAsync(count).Result;
                    if (devices.Count<Device>() > 0)
                    {
                        result = new List<IDictionary<string, object>>();
                        foreach (Device device in devices)
                        {
                            result.Add(new Dictionary<String, object>() { { "guid", device.Id }, { "connectionstring", CreateDeviceConnectionString(device, iotHubConnectionString) } });
                        }
                    }
                }
                catch (Exception e)
                {
                    Console.WriteLine("Error: " + e.Message);
                }
            }
            return result;
        }

        private static String CreateDeviceConnectionString(Device device, string iotHubConnectionString)
        {
            StringBuilder deviceConnectionString = new StringBuilder();

            var hostName = String.Empty;
            var tokenArray = iotHubConnectionString.Split(';');
            for (int i = 0; i < tokenArray.Length; i++)
            {
                var keyValueArray = tokenArray[i].Split('=');
                if (keyValueArray[0] == "HostName")
                {
                    hostName = tokenArray[i] + ';';
                    break;
                }
            }

            if (!String.IsNullOrWhiteSpace(hostName))
            {
                deviceConnectionString.Append(hostName);
                deviceConnectionString.AppendFormat("DeviceId={0}", device.Id);

                if (device.Authentication != null)
                {
                    if ((device.Authentication.SymmetricKey != null) && (device.Authentication.SymmetricKey.PrimaryKey != null))
                    {
                        deviceConnectionString.AppendFormat(";SharedAccessKey={0}", device.Authentication.SymmetricKey.PrimaryKey);
                    }
                    else
                    {
                        deviceConnectionString.AppendFormat(";x509=true");
                    }
                }
            }
            return deviceConnectionString.ToString();
        }
    }
}