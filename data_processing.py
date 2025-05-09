import pandas as pd
import numpy as np

card_data = pd.read_csv('/Users/grigorovakarina/Documents/GitHub/project2/data/cards_data.csv')
card_data.drop_duplicates(subset='id')
card_data.to_csv('/Users/grigorovakarina/Documents/GitHub/project2/data/card_data1.csv')

transaction_data = pd.read_csv('/Users/grigorovakarina/Documents/GitHub/project2/data/transactions_data.csv')
transaction_data.drop_duplicates(subset = 'id')
transaction_data.to_csv('/Users/grigorovakarina/Documents/GitHub/project2/data/transaction_data1.csv')

users_data = pd.read_csv('/Users/grigorovakarina/Documents/GitHub/project2/data/users_data.csv')
current_datetime = pd.Timestamp.now()
users_data['current_age'] = current_datetime.year - users_data['birth_year']
users_data.drop_duplicates(subset='id')
users_data.to_csv('/Users/grigorovakarina/Documents/GitHub/project2/data/users_data1.csv')

fraud_labels = pd.read_json('/Users/grigorovakarina/Documents/GitHub/project2/data/train_fraud_labels.json', orient = 'columns').reset_index()
fraud_labels.columns = ['fraud_index','is_fraud']
fraud_labels['is_fraud'] = fraud_labels['is_fraud'].map({'No': 0, 'Yes': 1})
is_fraud_yes = fraud_labels[fraud_labels['is_fraud'] == 1]
fraud_labels.to_csv('/Users/grigorovakarina/Documents/GitHub/project2/data/fraud_labels1.csv')

mcc_codes = pd.read_json('/Users/grigorovakarina/Documents/GitHub/project2/data/mcc_codes.json', orient = 'index').reset_index()
mcc_codes.columns = ['mcc_index','category']
mcc_codes.to_csv('/Users/grigorovakarina/Documents/GitHub/project2/data/mcc_codes1.csv')


