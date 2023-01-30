# import libraries
import sys
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
sns.set_style('darkgrid')
sns.set_context('paper')

# reading input file
input_file = open("1805112.txt", "r")
lines = input_file.readlines()
input_file.close()

# creating output lists
throughput = []
delay = []
delivery = []
drop = []
area_size = ["250x250", "500x500", "750x750", "1000x1000", "1250x1250"]
node_count = [20, 40, 60, 80, 100]
flow_count = [10, 20, 30, 40, 50]

n = len(sys.argv)
if n != 2:
    print("Error: Invalid number of arguments")
    exit(1)

parameter_name = ""
parameters = []

if sys.argv[1] == "1":
    parameter_name = "Area Size (m x m)"
    parameters = area_size
elif sys.argv[1] == "2":
    parameter_name = "Node Count"
    parameters = node_count
elif sys.argv[1] == "3":
    parameter_name = "Flow Count"
    parameters = flow_count

# parsing the input file
for l in lines:
    if l.startswith("Network"):
        throughput.append(float(l.split(" ")[-2]))
    elif l.startswith("End"):
        delay.append(float(l.split(" ")[-2]))
    elif l.startswith("Packet delivery"):
        delivery.append(float(l.split(" ")[-2]))
    elif l.startswith("Packet drop"):
        drop.append(float(l.split(" ")[-2]))

# creating dataframes
df1 = pd.DataFrame(zip(parameters, throughput))
df1.columns = [parameter_name, 'Network Throughput']

df2 = pd.DataFrame(zip(parameters, delay))
df2.columns = [parameter_name, 'End to End Average Delay']

df3 = pd.DataFrame(zip(parameters, delivery))
df3.columns = [parameter_name, 'Packet Delivery Ratio']

df4 = pd.DataFrame(zip(parameters, drop))
df4.columns = [parameter_name, 'Packet Drop Ratio']

# plotting graphs
fig, axes = plt.subplots(figsize = (12,5))
sns.lineplot(data = df1, x=parameter_name, y='Network Throughput',  marker='o')
plt.title('Network Throughput vs ' + parameter_name)
plt.xlabel(parameter_name) 
plt.ylabel('Network Throughput (bits/sec)')


fig, axes = plt.subplots(figsize = (12,5))
sns.lineplot(data = df2, x=parameter_name, y='End to End Average Delay', marker='o')
plt.title('End to End Average Delay vs ' + parameter_name)
plt.xlabel(parameter_name) 
plt.ylabel('End to End Average Delay (sec)')


fig, axes = plt.subplots(figsize = (12,5))
sns.lineplot(data = df3, x= parameter_name, y='Packet Delivery Ratio',  marker='o')
plt.title('Packet Delivery Ratio vs ' + parameter_name)
plt.xlabel(parameter_name)
plt.ylabel('Packet Delivery Ratio (percent)')


fig, axes = plt.subplots(figsize = (12,5))
sns.lineplot(data = df4, x=parameter_name, y='Packet Drop Ratio',  marker='o')
plt.title('Packet Drop Ratio vs ' + parameter_name)
plt.xlabel(parameter_name) 
plt.ylabel('Packet Drop Ratio (percent)')

plt.show()