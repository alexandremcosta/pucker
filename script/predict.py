from pucker_utils import neural_network, ScalerEncoder # for unpickle joblib
import joblib
from flask import Flask, request, jsonify
import pandas as pd
import tensorflow as tf
    
app = Flask(__name__)

@app.route('/predict', methods=['POST'])
def predict():
    data = request.form.to_dict()
    df = pd.DataFrame([data])
    df = df.astype('float64')
    
    pipeline = None
    if 'river_rank' in df.columns:
        pipeline = river_pipeline
    elif 'turn_rank' in df.columns:
        pipeline = turn_pipeline
    else:
        pipeline = flop_pipeline
        
    with graph.as_default():
        result = pipeline.predict(df)
    return jsonify(result.tolist())

if __name__ == '__main__':
    flop_pipeline = joblib.load("flop.joblib")
    turn_pipeline = joblib.load("turn.joblib")
    river_pipeline = joblib.load("river.joblib")
    global graph # bugfix: https://github.com/keras-team/keras/issues/6462
    graph = tf.get_default_graph()
    app.run(port=8080)