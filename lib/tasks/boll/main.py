'''
1 输入参数 code: 期货合约 DCE.c2109(这里需要先获取生成当前交易的code list)
2 多空组合判断: 基于N组均线, 呈多头排列或者空头排列提示趋势

    最少2组均线, 决定周期
    ma5 > ma30

    如果3组(5,30,60)
    ma5 > ma30 and ma30 > ma60

3 当空头排列或者多头排列情况, 提示均线组合M情况, 当前状态为[多,空, unknown] 3种状态

4 开仓参数: [顺势, 逆势], [只开多, 只开空] 组合4个条件
    顺势
    4.1 在多头情况下, boll 触发上轨 开多
    4.2 在空头情况下, boll 触发下轨 开空
    
    逆势
    4.3 在多头情况下, boll 触发下轨 开多
    4.4 在空头情况下, boll 触发上轨 开空
    
5. boll 条件参数
    bar 周期: 60分钟(也可以是其他的周期定义)
    ta.BBANDS(close, timeperiod=5, nbdevup=2, nbdevdn=2, matype=0)
    计出过去 N=5 日收巿价的标准差, SD(Standard Deviation) ，Up 线为 N日平均线加 2 倍标准差， Down 线则为 N日平均线减 2 倍标准差。


6. 策略

    开仓(position 可以是顺也可以是逆, 按4的情况组合执行)
    open_position 开仓数字为固定手数

        if current_price > boll.up then open_position
        if current_price < boll.down then open_position
    
    加仓

        已经有持仓, 未触发平仓, 但是再次满足开仓条件, 视为加仓固定手数, 直到加仓满足总仓位 5%(参数)

    平仓
        
        止损: 浮亏为开仓价的-1%(参数), 全部平仓
        止盈:
            1. 中轨线突破然后回归, 即冲高回落(冲低回拉), 全部平仓
            2. 反向冲击 up/down 破轨, 平一半仓位.
            3. 持仓过夜

6. 品种选择
    创建品种跟踪列表, 针对每个品种分别设置交易策略. 同时跟踪的品种和算力, 账号绑定有关

'''


from tqsdk import TqReplay, TqAuth, TqApi, TargetPosTask, TqBacktest,TqAccount
from datetime import datetime
from datetime import date
import time
import pandas as pd
import joblib
import numpy as np
import sys
import os
import math
import yaml
from tqsdk import TqApi, TargetPosTask, TqBacktest,TqAccount

from tqsdk.ta import BOLL
#api = TqApi(TqAccount("G国泰君安", "26500132", "yu079124"))
# api = TqApi(TqAccount("H海通期货", "81180565", "yu079124"))

def get_order_num(account):
    n = config_params['position_size']
    if n is None or n == 0:
        n = 2
    return n

def get_yaml_data(yaml_file):

    # 打开yaml文件
    print("***获取yaml文件数据***")
    file = open(yaml_file, 'r', encoding="utf-8")
    file_data = file.read()
    file.close()
    
    print(file_data)
    print("类型：", type(file_data))

    # 将字符串转化为字典或列表
    print("***转化yaml数据为字典或列表***")
    data = yaml.load(file_data)
    print(data)
    print("类型：", type(data))
    return data

if len(sys.argv) < 2:
    print('请输入配置文件, 格式: python main.py config.yml')
    exit(0)

current_path = os.path.abspath(".")
yaml_path = os.path.join(current_path, sys.argv[1])
config_params = get_yaml_data(yaml_path)

if config_params['run_level'] == 'replay':

    acc = str(config_params['sim_account'])
    pwd = str(config_params['sim_pwd'])

    start_text = config_params['start_from']
    end_text = config_params['to_end']

    start_date = datetime.strptime(start_text, "%Y-%m-%d").date()
    end_date = datetime.strptime(end_text, "%Y-%m-%d").date()

    api = TqApi(web_gui=config_params['web_url'], backtest = TqBacktest(start_dt=start_date, end_dt=end_date), auth=TqAuth(acc, pwd))
else:
    if config_params['future_company'] == '' or config_params['future_account'] == '' or config_params['future_pwd'] == '':
        print('没有配置期货账号')
        exit(0)
    future_account = TqAccount(config_params['future_company'], config_params['future_account'], config_params['sim_pwd'])
    api = TqApi(future_account, auth=TqAuth(config_params['sim_account'], config_params['sim_pwd']))

# replay.set_replay_speed(10.0)

account = api.get_account()
print(account)

# 获取目标期货代码
symbol = config_params['symbol_code']
long_short_judgment = None

position = api.get_position(symbol) 
quote = api.get_quote(symbol)
target_pos = TargetPosTask(api, symbol)

# 获得  tick序列的引用
ticks = api.get_tick_serial(symbol)

# 获得  分钟级别长短期K线的引用
# klines_major = api.get_kline_serial(symbol, config_params['major_period'])
# klines_minor = api.get_kline_serial(symbol, config_params['minor_period'])
klines_1m = api.get_kline_serial(symbol, 60)
klines_boll = api.get_kline_serial(symbol, 60 * int(config_params['kbar_period']))
boll_up = 0
boll_mid = 0 
boll_bot = 0

break_long = False
break_short= False

while True:
    api.wait_update()

    # if api.is_changing(ticks):
    #     # ticks.iloc[-1]返回序列中最后一个tick
    #     print("tick变化", ticks.iloc[-1])
    
    # 判断最后一根K线的收盘价是否有变化
    if api.is_changing(klines_1m.iloc[-1],  "datetime"):
        # datetime: 自unix epoch(1970-01-01 00:00:00 GMT)以来的纳秒数
        # print("新K线", datetime.datetime.fromtimestamp(klines.iloc[-1]["datetime"] / 1e9))
        m_period = int(config_params['major_period'])
        s_period = int(config_params['minor_period'])
        major_ma = sum(klines_1m.close.iloc[-m_period:]) / m_period
        minor_ma = sum(klines_1m.close.iloc[-s_period:]) / s_period
        

        print(klines_1m.iloc[-1])
        # 趋势判断 默认 收盘, 5分钟, 60分钟组合 
        if config_params['long_short_judgment'] == 'auto':
            if minor_ma > major_ma:
                long_short_judgment = 'long'
            else:
                long_short_judgment = 'short'
        else:
            long_short_judgment = config_params['long_short_judgment']

    # 布林线处理
    if api.is_changing(klines_boll.iloc[-1],  "datetime"):
    
        boll=BOLL(klines_boll, int(config_params['boll_period']), 2)
        boll_up = list(boll["top"])[-1]
        boll_mid = list(boll["mid"])[-1] 
        boll_bot = list(boll["bottom"])[-1]



    if api.is_changing(quote):       
        '''
        开仓逻辑:
        给定多空趋势
        破boll 指标
        空仓时候开仓
        '''

        if long_short_judgment == 'long':
            # 多头时候boll down 开多
            if quote.last_price < boll_bot:
                #判断没有仓位
                if position.pos_long is None or position.pos_long == 0:
                    order_num = get_order_num(account)
                    target_pos.set_target_volume(order_num)
                    break_long = False
                    print("开多open long: ", quote.datetime, quote.last_price)

        if long_short_judgment== 'short':
            if quote.last_price > boll_up:
                if position.pos_short is None or position.pos_short == 0:  
                    order_num = get_order_num(account)
                    target_pos.set_target_volume(-order_num)
                    break_short = False
                    print("open short: ", quote.datetime, quote.last_price)

        '''
        止损, 止盈
        '''
        if position.pos_long is not None:
            if position.pos_long > 0:
                #止损 买入价的 -1% 
                if (1 - quote.last_price / position.open_price_long) > 0.01:
                    target_pos.set_target_volume(0)
                    print("close long: ", quote.datetime, quote.last_price, boll_up, boll_mid, boll_bot)

                #止盈
                '''
                1. 中轨线突破然后回归, 即冲高回落(冲低回拉), 全部平仓
                2. 反向冲击 up/down 破轨, 平一半仓位.
                '''
                if quote.last_price > boll_mid:
                    break_long = True
                
                if break_long and quote.last_price < boll_mid:
                    target_pos.set_target_volume(0)
                
                if quote.last_price > boll_up:
                    order_num = get_order_num(account)
                    target_pos.set_target_volume(math.ceil(order_num/2))

        if position.pos_short is not None:
            if position.pos_short > 0:
                #止损 买入价的 -1% 
                if (1 - position.open_price_short / quote.last_price ) > 0.01:
                    target_pos.set_target_volume(0)
                    print("close short: ", quote.datetime, quote.last_price, boll_up, boll_mid, boll_bot)

                #止盈
                '''
                1. 中轨线突破然后回归, 即冲高回落(冲低回拉), 全部平仓
                2. 反向冲击 up/down 破轨, 平一半仓位.
            
                '''

                if quote.last_price < boll_mid:
                    break_short = True
                
                if break_short and quote.last_price > boll_mid:
                    target_pos.set_target_volume(0)
                
                if quote.last_price < boll_bot:
                    order_num = get_order_num(account)
                    target_pos.set_target_volume(math.ceil(-order_num/2))

