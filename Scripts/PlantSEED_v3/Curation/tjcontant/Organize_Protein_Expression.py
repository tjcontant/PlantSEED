import os,sys,json,csv,math
import pandas as pd
from pprint import pprint
from tqdm import tqdm
import time

# read in csv data as dataframe
df = pd.read_csv('../../../../../../Argonne/2022/local/Brapa_Expression.csv')

# get list of genes
genes = df['Unnamed: 0'].tolist()

# get list of replicates: "treatment_plant_replicate"
replicates = df.columns.tolist()
replicates.pop(0)


# create dictionary
exp_dict = dict()
for column in tqdm(range(0, len(replicates))):
    (treatment, plant, replicate) = replicates[column].split('_')
    if plant not in exp_dict.keys():
        exp_dict[plant] = {}
    exp_dict[plant][treatment] = {}
    exp_dict[plant][treatment][replicate] = {}
    for gene in genes:
        exp_dict[plant][treatment][replicate][gene] = df[replicates[column]][genes.index(gene)]

for plant in exp_dict.keys():
    for treatment in exp_dict[plant].keys():
        sum = 0
        count = 0
        for replicate in exp_dict[plant][treatment].keys():
            for gene in exp_dict[plant][treatment][replicate].keys():
                sum += exp_dict[plant][treatment][replicate][gene]
                count += 1
        exp_dict[plant][treatment]['average'] = None
        if count != 0:
            exp_dict[plant][treatment]['average'] = sum / count

# locally save dictionary as json file
with open('../../../../../../Argonne/2022/local/Brapa_Expression.json', 'w') as json_file:
    json.dump(exp_dict, json_file, indent = 4)