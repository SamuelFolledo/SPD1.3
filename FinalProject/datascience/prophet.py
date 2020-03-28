# Load packages
import os
import csv
import os.path
import datetime
import numpy as np
import pandas as pd
from pathlib import Path
from fbprophet import Prophet
from dateutil.easter import easter
from itertools import zip_longest
import pandas_datareader.data as web
from flask import Flask, render_template, request, redirect
from alpha_vantage.timeseries import TimeSeries
import datetime 


app = Flask(__name__)

@app.after_request
def add_header(response):
    response.headers['X-UA-Compatible'] = 'IE=Edge,chrome=1'
    response.headers['Cache-Control'] = 'public, max-age=0'
    return response
    
@app.route("/")
def first_page():
    tmp = Path("static/prophet.png")
    tmp_csv = Path("static/CSV.csv")
    if tmp.is_file():
        os.remove(tmp)
    if tmp_csv.is_file():
        os.remove(tmp_csv)
    return render_template("index.html")

#function to get stock data
def yahoo_stocks(symbol, start, end):
    return web.DataReader(symbol, 'yahoo', start, end)

def get_historical_stock_price(stock):
    print ("Getting historical stock prices for stock ", stock)
    d = datetime.datetime.today() # makes object for current time today
    #get 7 year stock data for Apple
    startDate = datetime.datetime(2019, 1, 4)
    date = datetime.datetime.now().date()
    #endDate = pd.to_datetime(date)
    #endDate = datetime.datetime(2020, 1, 28)
    stockData = yahoo_stocks(stock, startDate, date)
    return stockData

@app.route("/plot" , methods = ['POST', 'GET'] )
def main():
    if request.method == 'POST':
        stock = request.form['companyname']
        df_whole = get_historical_stock_price(stock)

        df = df_whole.filter(['Close'])
        
        df['ds'] = df.index
        df['y'] = np.log(df['Close'])
        original_end = df['Close'][-1]
        
        model = Prophet()
        model.fit(df)

        num_days = 20
        future = model.make_future_dataframe(periods=num_days)
        forecast = model.predict(future)
        
        print (forecast[['ds', 'yhat', 'yhat_lower', 'yhat_upper']].tail())
        
        df.set_index('ds', inplace=True)
        forecast.set_index('ds', inplace=True)
        
        viz_df = df.join(forecast[['yhat', 'yhat_lower','yhat_upper']], how = 'outer')
        viz_df['yhat_scaled'] = np.exp(viz_df['yhat'])

        close_data = viz_df.Close
        forecasted_data = viz_df.yhat_scaled
        date = future['ds']
        forecast_start = forecasted_data[-num_days]

        d = [date, close_data, forecasted_data]
        export_data = zip_longest(*d, fillvalue = '')
        with open('static/CSV.csv', 'w', encoding="ISO-8859-1", newline='') as myfile:
            wr = csv.writer(myfile)
            wr.writerow(("Date", "Actual", "Forecasted"))
            wr.writerows(export_data)
        myfile.close()
        return render_template("plot.html", original = round(original_end,2), forecast = round(forecast_start,2), stock_tinker = stock.upper())

if __name__ == "__main__":
    app.run(debug=True, threaded=True)
