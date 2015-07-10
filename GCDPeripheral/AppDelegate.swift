//
//  AppDelegate.swift
//  GCDPeripheral
//
//  Created by travis on 2015-07-09.
//  Copyright (c) 2015 C4. All rights reserved.
//

import UIKit

@UIApplicationMain
public class AppDelegate: UIResponder, UIApplicationDelegate, NSNetServiceBrowserDelegate, NSNetServiceDelegate, GCDAsyncSocketDelegate {
    var netServiceBrowser : NSNetServiceBrowser?
    var serverService : NSNetService?
    var serverAddresses : [NSData]?
    var asyncSocket : GCDAsyncSocket?
    var connected = false
    var vc : ViewController?

    public var window: UIWindow?

    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        netServiceBrowser = NSNetServiceBrowser()
        netServiceBrowser?.delegate = self
        netServiceBrowser?.searchForServicesOfType("_m-o._tcp.", inDomain: "local.")
        vc = self.window?.rootViewController as? ViewController

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "tapped:", name: "tapped", object: nil)
        
        return true
    }

    public func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    public func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    public func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    public func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    public func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        println("applicationWillTerminate")
        asyncSocket?.disconnect()
    }

    public func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        println("didFindDomain")
    }

    public func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
        println("didFindService")

        if serverService != nil {
            serverService?.stop()
            serverService?.delegate =  nil
        }
        serverService = aNetService;
        serverService?.delegate = self
        serverService?.resolveWithTimeout(5.0)
    }

    public func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didNotSearch errorDict: [NSObject : AnyObject]) {
        println("didNotSearch \(errorDict)")
    }

    public func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {
        println("didRemoveDomain")
    }

    public func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveService aNetService: NSNetService, moreComing: Bool) {
        println("didRemoveService")
        asyncSocket?.disconnect()
    }

    public func netServiceBrowserDidStopSearch(aNetServiceBrowser: NSNetServiceBrowser) {
        println("didStopSearch")
    }

    public func netServiceBrowserWillSearch(aNetServiceBrowser: NSNetServiceBrowser) {
        println("willSearch")
    }

    public func netServiceDidResolveAddress(sender: NSNetService) {
        println("resolved")
        if serverAddresses != nil {
            serverAddresses?.removeAll(keepCapacity: false)
        } else {
            serverAddresses = [NSData]()
        }

        if let count = sender.addresses?.count,
            let addresses = sender.addresses as? [NSData] {
                for i in 0..<count {
                    serverAddresses?.append(addresses[i])
                }
        }

        if (asyncSocket == nil) {
            asyncSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        }

        connectToNextAddress()
    }

    public func netService(sender: NSNetService, didNotResolve errorDict: [NSObject : AnyObject]) {
        println("didNotResolve")
    }

    public func connectToNextAddress() {
        var done = false

        println(serverAddresses?.count)
        while !done && serverAddresses?.count > 0 {
            var address = serverAddresses?[0]
            serverAddresses?.removeAtIndex(0)
            var error : NSError?
            if let response = asyncSocket?.connectToAddress(address , error: &error) {
                done = response
            }
        }
    }

    public func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        println("did connect")
        let handshake = "handshake-from-peripheral".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        let md = NSMutableData()
        md.appendData(handshake!)
        md.appendData(GCDAsyncSocket.CRLFData())
        sock.writeData(md, withTimeout: -1, tag: 0)
        sock.readDataToData(GCDAsyncSocket.CRLFData(), withTimeout: -1, tag: 0)
    }

    public func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        println("disconnected")
        asyncSocket?.disconnect()
        connectToNextAddress()
    }

    public func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        if let d = NSString(data: data, encoding: NSUTF8StringEncoding) {
            println(d)
            vc?.label.text = d as String
        }

        sock.readDataWithTimeout(-1, tag: 0)
    }

    public func socket(sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        println("didWriteDataWithTag")
    }

    public func socket(sock: GCDAsyncSocket!, didReadPartialDataOfLength partialLength: UInt, tag: Int) {
        println("didReadPartialDataOfLength")
    }
    
    public func tapped(notification: NSNotification) {
        if let d = notification.userInfo as? [String:AnyObject] {
            if let l = d["location"] as? String {
                let message = "tap|\(l)"
                
            } else {
                println("couldn't extract location from dictionary")
            }
        } else {
            println("couldn't extract userInfo from notification")
        }
    }
}

