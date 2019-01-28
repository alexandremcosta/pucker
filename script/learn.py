# Get Data
import sqlite3
import pandas as pd

conn = sqlite3.connect('../db/pucker.sqlite3')

df = pd.read_sql_query("SELECT * FROM states", conn)
df = df.loc[:, 'total_players':'reward'] # Remove ID

df_flop = df[df.turn_rank.isnull() & df.river_rank.isnull()]
df_flop = df_flop.drop(['turn_rank', 'turn_suit', 'river_rank', 'river_suit'], axis=1)

Xflop = df_flop.loc[:, 'total_players':'decision_raise']
yflop = df_flop.loc[:, 'reward']
yflop = pd.DataFrame([1 if item > 0 else 0 for item in yflop])

df_turn = df[df.turn_rank.notnull() & df.river_rank.isnull()]
df_turn = df_turn.drop(['river_rank', 'river_suit'], axis=1)

Xturn = df_turn.loc[:, 'total_players':'decision_raise']
yturn = df_turn.loc[:, 'reward']

df_river = df[df.turn_rank.notnull() & df.river_rank.notnull()]

Xriver = df_river.loc[:, 'total_players':'decision_raise']
yriver = df_river.loc[:, 'reward']
    
    
# Encode and scale
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.compose import make_column_transformer

def remove_multiple(collection, unwanted):
    collection = list(collection)
    unwanted = list(unwanted)
    return [item for item in collection if item not in unwanted]

def process(data):
    encode_columns = [item for item in data.columns if 'suit' in item]
    scale_columns = remove_multiple(data.columns, encode_columns)

    column_transformer = make_column_transformer(
        (StandardScaler(), scale_columns),
        (OneHotEncoder(categories='auto'), encode_columns))

    return column_transformer.fit_transform(data)
    
    
# Build and fit neural networks
from keras.models import Sequential
from keras.layers import Dense

def neural_network(nfeatures):
    model = Sequential()

    model.add(Dense(input_dim=nfeatures, units=1000, activation='relu', kernel_initializer='random_normal'))
    model.add(Dense(units=1000, activation='relu', kernel_initializer='random_normal'))
    model.add(Dense(units=1000, activation='relu', kernel_initializer='random_normal'))
    model.add(Dense(units=1000, activation='relu', kernel_initializer='random_normal'))
    model.add(Dense(units=1000, activation='relu', kernel_initializer='random_normal'))
    model.add(Dense(units=1000, activation='relu', kernel_initializer='random_normal'))
    model.add(Dense(units=1000, activation='tanh', kernel_initializer='glorot_normal'))
    model.add(Dense(units=1000, activation='tanh', kernel_initializer='glorot_normal'))
    model.add(Dense(units=1, activation='linear', kernel_initializer='random_normal'))

    model.compile(optimizer='adam', loss='mae', metrics=['mae'])

    return model

def flop_model(Xtrain, ytrain):
    model = Sequential()
    
    model.add(Dense(input_dim=Xtrain.shape[1], units=1000, activation='relu', kernel_initializer='random_normal'))
    model.add(Dense(units=1000, activation='relu', kernel_initializer='random_normal'))
    model.add(Dense(units=1000, activation='relu', kernel_initializer='random_normal'))
    model.add(Dense(units=1000, activation='relu', kernel_initializer='random_normal'))
    model.add(Dense(units=1000, activation='relu', kernel_initializer='random_normal'))
    model.add(Dense(units=1000, activation='relu', kernel_initializer='random_normal'))
    model.add(Dense(units=1000, activation='tanh', kernel_initializer='glorot_normal'))
    model.add(Dense(units=1000, activation='tanh', kernel_initializer='glorot_normal'))
    model.add(Dense(units=1, activation='sigmoid', kernel_initializer='random_normal'))

    model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy', 'mae'])
  
    model.fit(Xtrain, ytrain, batch_size=5000, epochs=25)
    
    return model
    
    
# Run
from sklearn.model_selection import train_test_split

def predict(fit_model, X, y):
    Xtrain, Xtest, ytrain, ytest = train_test_split(X, y, test_size=0.2, random_state=0)  
    model = fit_model(Xtrain, ytrain)
    ypred = model.predict(Xtest)
    return (ytest, ypred)
    
    
# Metrics
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
    print('Mean abs error: ', mean_absolute_error(ytest, ypred))    


# Main
# df_flop = df_flop[df_flop.position_over_all > 2]
# Xflop = df_flop.loc[:, 'total_players':'decision_raise']
# yflop = df_flop.loc[:, 'reward']

X = process(Xflop)
y = yflop.values

ytest, ypred = predict(flop_model, X, y)
evaluate(ytest, ypred)