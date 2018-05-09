﻿<!--
//  ---------------------------------------------------------------------------------
//  Copyright (c) Microsoft Open Technologies, Inc.  All rights reserved.
// 
//  The MIT License (MIT)
// 
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  ---------------------------------------------------------------------------------
-->

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="ConnectTheDotsWebSite.Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Connect BIG BIG The Dots</title>

    <!-- general styles -->
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.9/css/jquery.dataTables.css" />
    <link rel="stylesheet" type="text/css" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css" />
    <link rel="stylesheet" type="text/css" href="css/connectthedots.css" />
</head>
<body>
    <div class="globalSettings" style="display:none">
        <div class="ForceSocketCloseOnUserActionsTimeout"><%= ForceSocketCloseOnUserActionsTimeout %></div>
    </div>
    
    <div id="loading" style="display: none;">
        <div id="loading-inner">
            <p id="loading-text">Loading last 10 minutes of data...</p>
            <p id="loading-sensor"></p>
            <img id="loading-image" src="img/ajax-loader.gif" />
        </div>
    </div>

    <ul id="deviceMenu" style="display:none;">
        <li><div>Add a new device</div></li>
        <li><div>Remove device</div></li>
        <li><div>Get QRCode</div></li>
    </ul>

    <div id="qrcode">
    </div>

    <div id="add-device-dialog-form" title="Add new device" style="display: none;">
      <p>Type in a unique name for the new device (only characters and numbers).</p>
 
      <form>
        <fieldset style="padding:0; border:0; margin-top:25px; ">
          <label style="display:block;" for="newdeviceid">Device ID</label>
          <input type="text" name="newdeviceid" id="newdeviceid" value="mynewdevice" class="text ui-widget-content ui-corner-all" style="display:block;"/>
           <!-- Allow form submission with keyboard without duplicating the dialog button -->
          <input class="popup-input" type="submit" tabindex="-1" style="position:absolute; top:-1000px"/>
        </fieldset>
      </form>
    </div>

    <div id="delete-device-dialog-confirm" title="Delete device?" style="display: none;">
        <p><span class="ui-icon ui-icon-alert" style="float:left; margin:12px 12px 20px 0;"></span>This will permanently remove the device from the IoT Hub device registry. Are you sure?</p>
        <div id="devicetodelete"></div>
    </div>

    <div id="header">
        <div>
            <img src="img/ConnectTheDotsLogo.png" />
        </div>
    </div>


    <form id="form2" runat="server">
        <div id="user" runat="server">
        </div>

        <asp:ScriptManager ID='ScriptManager1' runat='server' EnablePageMethods='true' />
        <a target="_blank" href="http://connectthedots.io"><img style="position: absolute; top: 0; right: 0; border: 0;" src="img/forkme_CTD.png" alt="Fork me on GitHub" /></a>

        <div class="big-block">
            <h3>Live Sensor Data</h3>

            <div style="float: left; width: 200px">

                <p><strong>Select Sensor/R-PI:</strong></p>

            <div id="controllersContainer">
            </div>

            </div>
            <div id="chartsContainer">
            </div>
        </div>

        <div class="big-block">
            <h3>Real Time Events</h3>
            <div id="alerts">
                <table id="alertTable">
                    <thead>
                        <tr>
                            <th class="timeFromDate">Time</th>
                            <th>Device</th>
                            <th>Alert</th>
                            <th>Message</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>

            </div>
        </div>

        <div class="big-block">
            <h3>Devices List</h3>
            <div id="devices">
                <table id="devicesTable">
                    <thead>
                        <tr>
                            <th>Display Name</th>
                            <th>Location</th>
                            <th>IP Address</th>
                            <th>IoTHub Device ID</th>
                            <th id="cscolumn" runat="server">Connection String</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="big-block">
            <h3>Messages</h3>
            <div id="messages"></div>
        </div>
    </form>

    <script type="text/javascript" src="https://code.jquery.com/jquery-1.12.4.min.js"></script>
    <script type="text/javascript" src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
    <script type="text/javascript" src="https://cdn.datatables.net/1.10.9/js/jquery.dataTables.min.js"></script>
    <script type="text/javascript" src="https://d3js.org/d3.v3.min.js" charset="utf-8"></script>
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/d3-tip/0.7.1/d3-tip.js"></script>

    <script type="text/javascript" src="js/d3utils.js"></script>
    <script type="text/javascript" src="js/d3DataFlow.js"></script>
    <script type="text/javascript" src="js/d3Chart.js"></script>
    <script type="text/javascript" src="js/d3ChartControl.js"></script>
    <script type="text/javascript" src="js/d3DataSourceSocket.js"></script>
    <script type="text/javascript" src="js/d3CTDDataSourceSocket.js"></script>
    <script type="text/javascript" src="js/d3CTDDataSourceFilter.js"></script>
    <script type="text/javascript" src="js/jquery.ui-contextmenu.js"></script>
    <script type="text/javascript" src="js/devicesList.js"></script>
    <script type="text/javascript" src="js/qrcode.js"></script>
    <script type="text/javascript" src="js/d3CTD.js"></script>
</body>
</html>
