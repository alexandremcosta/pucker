# Encode and scale
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.compose import make_column_transformer
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.exceptions import DataConversionWarning
import warnings
warnings.filterwarnings(action='ignore', category=DataConversionWarning)

class ScalerEncoder(BaseEstimator, TransformerMixin):        
    def fit(self, X, y):
        encode_columns = [item for item in X.columns if 'suit' in item]
        scale_columns = [item for item in X.columns if item not in encode_columns]
        
        self.column_transformer = make_column_transformer(
            (StandardScaler(), scale_columns),
            (OneHotEncoder(categories='auto'), encode_columns))
        self.column_transformer.fit(X)
        
        return self

    def transform(self, X):
        return self.column_transformer.transform(X)
    
# Build and fit neural networks
from keras.models import Sequential
from keras.layers import Dense

def neural_network_1000_6(input_dim=None):
    nn = Sequential()
    
    nn.add(Dense(input_dim=input_dim, units=1000, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=1000, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=1000, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=1000, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=1000, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=1000, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=1, activation='linear', kernel_initializer='random_normal'))
    
    nn.compile(optimizer='adam', loss='mae', metrics=['mae'])
    return nn

def neural_network_500_12(input_dim=None):
    nn = Sequential()
    
    nn.add(Dense(input_dim=input_dim, units=500, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=500, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=500, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=500, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=500, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=500, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=500, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=500, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=500, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=500, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=500, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=500, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=1, activation='linear', kernel_initializer='random_normal'))
    
    nn.compile(optimizer='adam', loss='mae', metrics=['mae'])
    return nn

def neural_network_250_24(input_dim=None):
    nn = Sequential()
    
    nn.add(Dense(input_dim=input_dim, units=250, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=250, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=250, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=250, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=250, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=250, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=250, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=250, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=250, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=250, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=250, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=250, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=250, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=250, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=250, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=250, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=250, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=250, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=250, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=250, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=250, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=250, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=250, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=250, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=1, activation='linear', kernel_initializer='random_normal'))
    
    nn.compile(optimizer='adam', loss='mae', metrics=['mae'])
    return nn

def neural_network_700_6(input_dim=None):
    nn = Sequential()
    
    nn.add(Dense(input_dim=input_dim, units=700, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=700, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=700, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=700, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=700, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=700, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=1, activation='linear', kernel_initializer='random_normal'))
    
    nn.compile(optimizer='adam', loss='mae', metrics=['mae'])
    return nn

def neural_network_350_12(input_dim=None):
    nn = Sequential()
    
    nn.add(Dense(input_dim=input_dim, units=350, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=350, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=350, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=350, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=350, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=350, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=350, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=350, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=350, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=350, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=350, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=350, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=1, activation='linear', kernel_initializer='random_normal'))
    
    nn.compile(optimizer='adam', loss='mae', metrics=['mae'])
    return nn

def neural_network_175_24(input_dim=None):
    nn = Sequential()
    
    nn.add(Dense(input_dim=input_dim, units=175, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=175, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=175, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=175, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=175, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=175, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=175, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=175, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=175, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=175, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=175, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=175, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=175, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=175, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=175, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=175, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=175, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=175, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=175, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=175, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=175, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=175, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=175, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=175, activation='relu', kernel_initializer='random_normal'))
    nn.add(Dense(units=1, activation='linear', kernel_initializer='random_normal'))

    
    nn.compile(optimizer='adam', loss='mae', metrics=['mae'])
    return nn