

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var etherValueLabel: UILabel!
    
    /// The CryptoCompare API URL here returns the value of 1 ETH in USD
    let apiURL = URL(string: "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // unwraping URL
        guard let apiURL = apiURL else {
            return
        }
        
        // geting back value in NSNumber format using unwrapped URL
        makeValueGETRequest(url: apiURL) { (value) in
            // making UI being updated on the main thread (GET request works in background)
            DispatchQueue.main.async {
                // setting the label with value or "Failed"
                self.etherValueLabel.text = self.formatAsCurrencyString(value: value) ?? "Failed"
            }
        }
    }


    // takes in URL, and contains completion block which returns an optional value
    // escaping closure that allowed to be call after function returns
    private func makeValueGETRequest(url: URL, completion: @escaping (_ value: NSNumber?) -> Void) {
        
        // request returns data from call, response(info about call itself) and optinal error in case of failure
        let request = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            // confirms that data isn't nil and there weren't any errors
            guard let data = data, error == nil else {
                completion(nil)
                // using nil coalescing operator - it unwrap the optional value and in case of nil returns empty string
                print(error?.localizedDescription ?? "")
                return
            }
            
            // fetching JSON response from server (USD value)
            do {
                // Unwrap the JSON dictionary and read the USD key which has the value of Ethereum
                guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                    let value = json["USD"] as? NSNumber else {
                        completion(nil)
                        return
                }
                completion(value)
            } catch {
                // in case of JSON couldn't be serialize - setting complition as nil
                completion(nil)
                print(error.localizedDescription)
            }
        }
        // starts a call
        request.resume()
    }
    
    // helper function for converting value number to US currency string
    private func formatAsCurrencyString(value: NSNumber?) -> String? {
        // class that takes the numbers and represents them in various text formats
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        
        guard let value = value,
            let formattedCurrencyAmount = formatter.string(from: value) else {
            return nil
        }
        return formattedCurrencyAmount
    }


}













