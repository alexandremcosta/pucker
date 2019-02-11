#!/usr/bin/python3

from pucker_utils import neural_network_1000_6, neural_network_700_6, neural_network_350_12, neural_network_175_24, ScalerEncoder # required by unpicle joblib
from flask import Flask, request, jsonify
import joblib
import pandas as pd
import tensorflow as tf

# Run with 1/2 GPU memory cap
# One server predicts for 2 clients
import keras
memory_fraction = tf.GPUOptions(per_process_gpu_memory_fraction=0.4)
keras.backend.set_session(tf.Session(config=tf.ConfigProto(gpu_options=memory_fraction)))

app = Flask(__name__)

def predict(pipeline, df):
    with graph.as_default(): # bugfix: https://github.com/keras-team/keras/issues/6462
        result = pipeline.predict(df)
    return jsonify(result.tolist())

def request_to_dataframe(request):
    data = request.form.to_dict()
    df = pd.DataFrame([data])
    return df.astype('float64')

@app.route('/pred_1000', methods=['POST'])
def pred_1000():
    df = request_to_dataframe(request)
    
    pipeline = None
    if 'river_rank' in df.columns:
        pipeline = river_pipeline_1000
    elif 'turn_rank' in df.columns:
        pipeline = turn_pipeline_1000
    else:
        pipeline = flop_pipeline_1000
    
    return predict(pipeline, df)

@app.route('/pred_700', methods=['POST'])
def pred_700():
    df = request_to_dataframe(request)
    
    pipeline = None
    if 'river_rank' in df.columns:
        pipeline = river_pipeline_700
    elif 'turn_rank' in df.columns:
        pipeline = turn_pipeline_700
    else:
        pipeline = flop_pipeline_700
        
    return predict(pipeline, df)

@app.route('/pred_350', methods=['POST'])
def pred_350():
    df = request_to_dataframe(request)
    
    pipeline = None
    if 'river_rank' in df.columns:
        pipeline = river_pipeline_350
    elif 'turn_rank' in df.columns:
        pipeline = turn_pipeline_350
    else:
        pipeline = flop_pipeline_350
        
    return predict(pipeline, df)

@app.route('/pred_175', methods=['POST'])
def pred_175():
    df = request_to_dataframe(request)
    
    pipeline = None
    if 'river_rank' in df.columns:
        pipeline = river_pipeline_175
    elif 'turn_rank' in df.columns:
        pipeline = turn_pipeline_175
    else:
        pipeline = flop_pipeline_175
    
    return predict(pipeline, df)

if __name__ == '__main__':
    global graph # bugfix: https://github.com/keras-team/keras/issues/6462
    graph = tf.get_default_graph()

    flop_pipeline_1000  = joblib.load("script/flop_1000_6.joblib")
    turn_pipeline_1000  = joblib.load("script/turn_1000_6.joblib")
    river_pipeline_1000 = joblib.load("script/river_1000_6.joblib")
    flop_pipeline_700   = joblib.load("script/flop_700_6.joblib")
    turn_pipeline_700   = joblib.load("script/turn_700_6.joblib")
    river_pipeline_700  = joblib.load("script/river_700_6.joblib")
    flop_pipeline_350   = joblib.load("script/flop_350_12.joblib")
    turn_pipeline_350   = joblib.load("script/turn_350_12.joblib")
    river_pipeline_350  = joblib.load("script/river_350_12.joblib")
    flop_pipeline_175   = joblib.load("script/flop_175_24.joblib")
    turn_pipeline_175   = joblib.load("script/turn_175_24.joblib")
    river_pipeline_175  = joblib.load("script/river_175_24.joblib")

    app.run(port=8081)
