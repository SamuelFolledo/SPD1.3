//
//  Networking.swift
//  ZeusApp
//
//  Created by Macbook Pro 15 on 2/12/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import Foundation

struct UserAPI: Encodable { //sending
    let email: String
    let password: String
}

struct Token: Decodable { //receiving
    let token: String
}

struct Message: Decodable {
    let success: String
}

struct StockCodable: Codable {
    let symbol: String
    let price: Double
}

//MARK: Network Calls
///POST get Stock details
func fetchStockDetails(stock: Stock, token: String, completion: @escaping(_ error: String?, _ user: Stock?) -> Void) {
    let stock = stock
    let shortName = stock.shortName.uppercased().trimmingCharacters(in: .whitespacesAndNewlines) //removes white spaces
    let url = URL(string: "https://financialmodelingprep.com/api/v3/company/profile/\(shortName)")
//    let url = URL(string: "https://financialmodelingprep.com/api/v3/real-time-price/\(shortName)")
    var request = URLRequest(url: url!)
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    let task = URLSession.shared.dataTask(with: url!) { data, response, error in
        guard error == nil else {
            print(error!)
            return
        }
        guard let data = data else {
            print("Data is empty")
            return
        }

//        do {
        let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: [])
        guard let profileResponse = jsonResponse as? [String: Any] else { completion("Error converting json received", nil); return }
        guard let companyResponse = profileResponse["profile"] as? [String: Any] else { print("Couldnt get company profile"); return } //company details is inside profile
//        print ("Response: \(companyResponse)")
        guard let price = companyResponse[kPRICE] as? Double else { print("Couldnt get price"); return }
        //get the entire string after USD
        stock.price = String(format: "%.2f", ceil(price*100)/100) //2 decimal points
        guard let changesPercentage = companyResponse["changesPercentage"] as? String else { print("Couldnt get changesPercentage"); return }
//        print("changesPercentage= \(changesPercentage)")
        var isPositive = false
        for char in changesPercentage where char == "-" || char == "+" { //look for first instance of + or -
            isPositive = char == "+" ? true : false
            break
        }
        stock.isPositive = isPositive
        completion(nil, stock)
//        } catch _ {
//            //                    completion("JSON not formatted", nil)
//            print("\(shortName) JSON cannot be formatted")
//            completion(nil, stock)
//        }
    }
    task.resume()
    
    
//    let companyDic: [String: Any] = ["ticker": shortName]
////    goRequestStocks()
////    let companyName = stock.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) //removes white spaces
////    print("Getting \(companyName)")
////    let companyDic: [String: Any] = [kCOMPANYNAME: companyName]
//    if (!JSONSerialization.isValidJSONObject(companyDic)) {
//            completion("Invalid Token data", nil)
//        }
//    let url: String = "http://3.17.150.127:5000/price"
//    let session = URLSession.shared
//    let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
//    request.httpMethod = "POST"
//    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//    request.addValue("application/json", forHTTPHeaderField: "Accept")
//    request.setValue(token, forHTTPHeaderField: kTOKEN) //sets the header
//    do {
//        request.httpBody = try JSONSerialization.data(withJSONObject: companyDic, options: .prettyPrinted) //sets the body
//
//        let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
//            if let response = response {
//                let nsHTTPResponse = response as! HTTPURLResponse
//                let statusCode = nsHTTPResponse.statusCode
//                print ("status code = \(statusCode)")
//            }
//            if let error = error {
//                print ("\(error)")
//            }
//            if let data = data {
////                do {
////                    let response = try JSONDecoder().decode(Token.self, from: data)
////                    print(response.token)
////                } catch { print(error) }
//                do { //MARK: On /create, error is JSON not formatted. On /user error is dataCorrupted... Invalid value around character
//                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
//                    print ("jsonResponse: \(jsonResponse)")
//                    guard let response = jsonResponse as? [String: Any] else { completion("Error converting json received", nil); return }
////                    guard let shortName = response[kSHORTNAME] as? String else { print("Couldnt get shortname"); return }
//                    //convert response[kPRICE] to a string
//                    guard let priceDetails = response[kPRICE] as? String else { return }
//                    //get the entire string after USD
//                    let prePrice = priceDetails.components(separatedBy: "USD")[1] //get the second element
//                    //remove all strings after + or -
//                    var characterToRemove: String = "" //+ or - or empty string
//                    for char in prePrice where char == "-" || char == "+" { //look for first instance of + or -
//                        characterToRemove = String(char)
//                        break
//                    }
//                    if characterToRemove == "+" || characterToRemove == "-" {
//                        let price = prePrice.components(separatedBy: characterToRemove)[0] //+ or -, remove the strings after it, giving us the actual price only
////                    guard let currentPrice = price as? String else { print("\(price) couldnt be turned into a double"); return }
////                    guard let currentPrice = response[kPRICE] as? Double else {print("Couldnt get price"); return }
////                    stock.price = String(format: "%.2f", ceil(currentPrice*100)/100) //2 decimal points
//                        stock.price = price
//                        let isPositive = characterToRemove == "+" ? true : false //if + then stock.isPositive = true
//                        stock.isPositive = isPositive
//                    } else {
//                        print("didn't find + or -")
//                    }
//                    completion(nil, stock)
//                } catch _ {
////                    completion("JSON not formatted", nil)
//                    print("\(shortName) JSON cannot be formatted")
//                    completion(nil, stock)
//                }
//            }
//        })
//        task.resume()
//    } catch _ {
//        print ("Some error :)")
//    }
}

func goRequestStocks(stock: Stock, token: String, completion: @escaping(_ error: String?, _ user: Stock?) -> Void) {
    let stock = stock
    let shortName = stock.shortName.trimmingCharacters(in: .whitespacesAndNewlines) //removes white spaces
    let companyDic: [String: Any] = ["ticker": shortName]
    //    let companyName = stock.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) //removes white spaces
    //    print("Getting \(companyName)")
    //    let companyDic: [String: Any] = [kCOMPANYNAME: companyName]
    if (!JSONSerialization.isValidJSONObject(companyDic)) {
        completion("Invalid Token data", nil)
    }
    let url: String = "http://3.17.150.127:5000/price"
    let session = URLSession.shared
    let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue(token, forHTTPHeaderField: kTOKEN) //sets the header
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: companyDic, options: .prettyPrinted) //sets the body
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let response = response {
                let nsHTTPResponse = response as! HTTPURLResponse
                let statusCode = nsHTTPResponse.statusCode
                print ("status code = \(statusCode)")
            }
            if let error = error {
                print ("\(error)")
            }
            if let data = data {
                //                do {
                //                    let response = try JSONDecoder().decode(Token.self, from: data)
                //                    print(response.token)
                //                } catch { print(error) }
                do { //MARK: On /create, error is JSON not formatted. On /user error is dataCorrupted... Invalid value around character
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                    print ("jsonResponse: \(jsonResponse)")
                    guard let response = jsonResponse as? [String: Any] else { completion("Error converting json received", nil); return }
                    //                    guard let shortName = response[kSHORTNAME] as? String else { print("Couldnt get shortname"); return }
                    //convert response[kPRICE] to a string
                    guard let priceDetails = response[kPRICE] as? String else { return }
                    //get the entire string after USD
                    let prePrice = priceDetails.components(separatedBy: "USD")[1] //get the second element
                    //remove all strings after + or -
                    var characterToRemove: String = "" //+ or - or empty string
                    for char in prePrice where char == "-" || char == "+" { //look for first instance of + or -
                        characterToRemove = String(char)
                        break
                    }
                    if characterToRemove == "+" || characterToRemove == "-" {
                        let price = prePrice.components(separatedBy: characterToRemove)[0] //+ or -, remove the strings after it, giving us the actual price only
                        //                    guard let currentPrice = price as? String else { print("\(price) couldnt be turned into a double"); return }
                        //                    guard let currentPrice = response[kPRICE] as? Double else {print("Couldnt get price"); return }
                        //                    stock.price = String(format: "%.2f", ceil(currentPrice*100)/100) //2 decimal points
                        stock.price = price
                        let isPositive = characterToRemove == "+" ? true : false //if + then stock.isPositive = true
                        stock.isPositive = isPositive
                    } else {
                        print("didn't find + or -")
                    }
                    completion(nil, stock)
                } catch _ {
                    //                    completion("JSON not formatted", nil)
                    print("\(shortName) JSON cannot be formatted")
                    completion(nil, stock)
                }
            }
        })
        task.resume()
    } catch _ {
        print ("Some error :)")
    }
}

///POST HTTP create user
func postRequest(url: String, userDic: [String: Any], completion: @escaping(_ error: String?, _ user: User?) -> Void) { //user for Registering user
    if (!JSONSerialization.isValidJSONObject(userDic)) {
        completion("Invalid email and password data", nil)
    }
    let session = URLSession.shared
    let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: userDic, options: .prettyPrinted)
        let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let response = response {
                let nsHTTPResponse = response as! HTTPURLResponse
                let statusCode = nsHTTPResponse.statusCode
                print ("status code = \(statusCode)")
            }
            if let error = error {
                print ("\(error)")
            }
            if let data = data {
//                do {
//                    let response = try JSONDecoder().decode(Token.self, from: data)
//                    print(response.token)
//                } catch { print(error) }
                do { //MARK: On /create, error is JSON not formatted. On /user error is dataCorrupted... Invalid value around character
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                    print ("jsonResponse: \(jsonResponse)")
                    guard let response = jsonResponse as? [String: Any] else { completion("Error converting json received", nil); return }
                    if let errorMessage = response[kMESSAGE] as? String { //if we get a message response, it means there is an error
                        print("Error = \(errorMessage)")
                        completion(errorMessage, nil)
                    }
                    if let token = response[kTOKEN] {
                        print("Token = ", token)
                        UserDefaults.standard.set(token, forKey: kTOKEN)
                        UserDefaults.standard.synchronize()
                    } else {
                        print("No token found")
                    }
                    if let _ = response["success"] { //if we have a success key then create user
                        let user = User(_dictionary: userDic)
                        completion(nil, user)
                    }
                    //Should not reach here, display unknown error
                    completion("Unknown response error", nil)
                } catch _ {
                    completion("JSON not formatted", nil)
                }
            }
        })
        task.resume()
    } catch _ {
        print ("Some error :)")
    }
}

func login(email: String, password: String, completion: @escaping(_ error: String?, _ user: User?) -> Void) {
    var userDic:[String: String] = [
        kEMAIL: email,
        "password": password,
    ]
    if (!JSONSerialization.isValidJSONObject(userDic)) {
        completion("Invalid email and password data", nil)
    }
    let session = URLSession.shared
    let url = "http://3.17.150.127:8000/login"
    let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: userDic, options: .prettyPrinted)
        let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let response = response {
                let nsHTTPResponse = response as! HTTPURLResponse
                let statusCode = nsHTTPResponse.statusCode
                print ("status code = \(statusCode)")
            }
            if let error = error {
                completion(error.localizedDescription, nil)
            }
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(Token.self, from: data) //MARK: Handle Error here in case request does not return any Token
                    userDic[kUSERID] = UUID().uuidString
                    userDic[kTOKEN] = response.token
                    print("Token \(response.token)")
                    UserDefaults.standard.set(response.token, forKey: kTOKEN)
                    UserDefaults.standard.synchronize()
                    getRequestUser(userDic: userDic) { (error, user) in
                        if let error = error {
                            completion(error, nil)
                        }
                        completion(nil, user!)
                    }
                } catch {
                    completion(error.localizedDescription, nil)
                }
//                do {
//                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
//                    print ("jsonResponse: \(jsonResponse)")
//                } catch _ { print ("JSON not formatted") }
            }
        })
        task.resume()
    } catch _ {
        completion("Login request error", nil)
    }
}

///Takes a token and performs a GET request from the API and returns a user from the database if no error
func getRequestUser(userDic: [String: Any], completion: @escaping(_ error: String?, _ user: User?) -> Void) {
    guard let token = userDic[kTOKEN] as? String else { completion("No token", nil); return }
    let session = URLSession.shared
    let url = "\(kAPIURL)/user"
    let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
    request.httpMethod = "GET"
    request.setValue(token, forHTTPHeaderField: "token") //set token to the header
    let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
        if let response = response {
            let nsHTTPResponse = response as! HTTPURLResponse
            let statusCode = nsHTTPResponse.statusCode
            print ("status code = \(statusCode)")
        }
        if let error = error {
            completion(error.localizedDescription, nil)
        }
        if let data = data {
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                print ("jsonResponse: \(jsonResponse)")
                guard let response = jsonResponse as? [String: Any] else { completion("Error converting json received", nil); return }
                if let errorMessage = response[kMESSAGE] as? String { //if we get a message response, it means there is an error
                    print("Error = \(errorMessage)")
                    completion(errorMessage, nil)
                }
                if let _ = response["success"] { //if we have a success key then create user
                    let user = User(_dictionary: userDic)
                    completion(nil, user)
                    return
                }
                if let token = response[kTOKEN] {
                    print("Token = ", token)
                } else {
                    print("No token found")
                }
                //Should not reach here, display unknown error
                completion("Unknown response error", nil)
//                let response = try JSONDecoder().decode(Message.self, from: data)
//                print(response.success)
//                let user = User(_dictionary: userDic)
//                completion(nil, user)
            } catch {
                completion(error.localizedDescription, nil)
            }
        }
    })
    task.resume()
}
