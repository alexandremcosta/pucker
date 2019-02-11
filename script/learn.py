from pucker_utils import neural_network_1000_6, neural_network_700_6, neural_network_350_12, neural_network_175_24, ScalerEncoder

# Get data
import sqlite3
import pandas as pd

conn = sqlite3.connect('../db/pucker_phase2.sqlite3')

df = pd.read_sql_query("SELECT * FROM states", conn)
df = df.loc[:, 'total_players':'reward'] # Remove ID

df_flop = df[df.turn_rank.isnull() & df.river_rank.isnull()]
df_flop = df_flop.drop(['turn_rank', 'turn_suit', 'river_rank', 'river_suit'], axis=1)

df_turn = df[df.turn_rank.notnull() & df.river_rank.isnull()]
df_turn = df_turn.drop(['river_rank', 'river_suit'], axis=1)

df_river = df[df.turn_rank.notnull() & df.river_rank.notnull()]
df_river = df_river.drop(['ppot', 'npot'], axis=1) # river hand has no potential to improve

def split_XY(dataframe):
    X = dataframe.loc[:, 'total_players':'decision_raise']
    y = dataframe.loc[:, 'reward']
    
    return(X, y.values)
    
    
def number_of_features(Xdata):
    encode_columns = [item for item in Xdata.columns if 'suit' in item]
    return Xdata.shape[1] + len(encode_columns)*4 - len(encode_columns)
    
    
# Evaluation
from sklearn.metrics import confusion_matrix, accuracy_score, precision_score, recall_score, f1_score, mean_absolute_error

def evaluate(ytest, ypred):
    true_result = [1 if item > 0.5 else 0 for item in ytest]
    pred_result = [1 if item > 0.5 else 0 for item in ypred]
    
    cm = confusion_matrix(true_result, pred_result)
    print('\nConfusion matrix:')
    print(cm)
    print("\nLoss classified as loss", cm[0][0])
    print("Wins classified as wins", cm[1][1])
    print("Wins classified as loss", cm[1][0])
    print("Loss classified as wins", cm[0][1])
    print('\nAccuracy:\t', accuracy_score(true_result, pred_result))
    print('Precision:\t', precision_score(true_result, pred_result))
    print('Recall: \t', recall_score(true_result, pred_result))
    print('F1 score:\t', f1_score(true_result, pred_result))
    print('Mean absolute error:\t', mean_absolute_error(ytest, ypred))


# Run and evaluate
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from keras.wrappers.scikit_learn import KerasRegressor
from keras.callbacks import EarlyStopping
import numpy

seed = 7 # fix random seed for reproducibility
numpy.random.seed(seed)

def run_and_evaluate(dataframe, model):
    X, y = split_XY(dataframe)
    Xtrain, Xtest, ytrain, ytest = train_test_split(X, y, test_size=0.2, random_state=0)
    
    early_stop = EarlyStopping(monitor='val_loss', patience=5, verbose=1, restore_best_weights=True)
    
    pipeline = Pipeline([
        ('preprocess', ScalerEncoder()),
        ('model', KerasRegressor(build_fn=model, input_dim=number_of_features(X), epochs=100, batch_size=1000, verbose=1, callbacks=[early_stop], validation_split=0.1))])
    
    pipeline.fit(Xtrain, ytrain)
    ypred = pipeline.predict(Xtest)

    evaluate(ytest, ypred)

def run_and_evaluate_all(model):
    print('FLOP:')
    run_and_evaluate(df_flop, model)
    print('TURN:')
    run_and_evaluate(df_turn, model)
    print('RIVER:')
    run_and_evaluate(df_river, model)

# run_and_evaluate_all(neural_network_175_24)

# Train full dataset and persist
import joblib

def train_persist(dataframe, model, filename):
    X, y = split_XY(dataframe)

    pipeline = Pipeline([
        ('preprocess', ScalerEncoder()),
        ('model', KerasRegressor(build_fn=model, input_dim=number_of_features(X), epochs=20, batch_size=1000, verbose=1))])
    
    pipeline.fit(X, y)
    joblib.dump(pipeline, filename)

train_persist(df_flop, neural_network_1000_6, 'flop_1000_6.joblib')
train_persist(df_turn, neural_network_1000_6, 'turn_1000_6.joblib')
train_persist(df_river, neural_network_1000_6, 'river_1000_6.joblib')

train_persist(df_flop, neural_network_700_6, 'flop_700_6.joblib')
train_persist(df_turn, neural_network_700_6, 'turn_700_6.joblib')
train_persist(df_river, neural_network_700_6, 'river_700_6.joblib')

train_persist(df_flop, neural_network_350_12, 'flop_350_12.joblib')
train_persist(df_turn, neural_network_350_12, 'turn_350_12.joblib')
train_persist(df_river, neural_network_350_12, 'river_350_12.joblib')

train_persist(df_flop, neural_network_175_24, 'flop_175_24.joblib')
train_persist(df_turn, neural_network_175_24, 'turn_175_24.joblib')
train_persist(df_river, neural_network_175_24, 'river_175_24.joblib')

# json samples
# import json
# xflop, yflop = split_XY(df_flop)
# parsed = json.loads(xflop.loc[0:1, :].to_json(orient = 'records'))
# print(json.dumps(parsed, indent=4))
