#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Feb  5 11:32:53 2019

@author: siyu
"""

import plotly.plotly as py
import plotly.graph_objs as go
import plotly
import plotly.io as pio
from IPython.display import Image
import pandas as pd
from geopy.geocoders import Nominatim

df1 = pd.read_csv('country_count.csv',header=None, names=['country','count'])
filter_data=df1[df1['count']>=100]

stack=[]
geolocator=Nominatim(user_agent="google")
for i in range(0,len(filter_data)):
    location = geolocator.geocode(filter_data['country'][i])
    country=filter_data['country'][i]
    count=filter_data['count'][i]
    latitude=location.latitude
    longtitude=location.longitude
    text=country+'<br>Publication count '+str(count)
    stack.append([country,count,latitude,longtitude,text])

data=pd.DataFrame(stack,columns=['country','count','latitude','longtitude','text'])
#py.iplot(fig1, filename='world-map.html')

#US map/California
df2 = pd.read_csv('us_city_count.csv',header=None, names=['city','count'])
filter_data2=df2[df2['count']>=50]
stack1=[]
stack2=[]
geolocator=Nominatim(user_agent="google")
for i in range(0,len(filter_data2)):
    location = geolocator.geocode(filter_data2['city'][i]+' USA')
    city=filter_data2['city'][i]
    count=filter_data2['count'][i]
    if location.address.split(',')[-2].strip().isdigit():
        state=location.address.split(',')[-3].strip()
    else:
        state=location.address.split(',')[-2].strip()
    latitude=location.latitude
    longtitude=location.longitude
    text=city+'<br>Publication count '+str(count)
    stack2.append([city,count,state,latitude,longtitude,text])

data2=pd.DataFrame(stack2,columns=['city','count','state','latitude','longtitude','text'])
cal=data2[data2['state']=='California']
state_wise=data2.groupby(['state'])['count'].sum()
for i in state_wise.keys():
    state=str(i)
    count=state_wise[i]
    location = geolocator.geocode(i+' USA')
    latitude=location.latitude
    longtitude=location.longitude
    text=state+'<br>Publication count '+str(count)
    stack1.append([state,count,latitude,longtitude,text])
state_map=pd.DataFrame(stack1,columns=['state','count','latitude','longtitude','text'])

scale = 1

cities = [dict(
    type = 'scattergeo',
    locationmode = "USA-states", #ISO-3 #USA-states
    lon = data2['longtitude'],
    lat = data2['latitude'],
    text = data2['text'],
    marker = dict(
        size = data2['count']/scale,
        #sizeref = 2. * max(data['count']/scale) / (25 ** 2),
        color = [19]*len(data2),
        sizemode = 'area',
        colorscale='Viridis'
    ),
    mode='markers',
    showlegend=False)]
        #name = '{0} - {1}'.format(lim[0],lim[1]) )
scatters=[go.Scattermapbox(
        lat=cal['latitude'],
        lon=cal['longtitude'],
        text=cal['text'],
        mode='markers',
        marker = dict(
                size = cal['count']/scale,
                #sizeref = 2. * max(data['count']/scale) / (25 ** 2),
                color = 9,
                sizemode = 'area',
                colorscale='Viridis'
        ))
    #showlegend=False)
    ]
        
layout_cal = go.Layout(
    autosize=True,
    hovermode='closest',
    mapbox=dict(
        accesstoken='pk.eyJ1Ijoic3lsaXUwNTE5IiwiYSI6ImNqcndtN2o3MTBlNnU0OXFydnA0NjNhMnIifQ.gGGmtFTT7gbUuTxsrhqiRQ',
        bearing=0,
        center=dict(
            lat=36.7783,
            lon=-119.4179
        ),
        pitch=0,
        zoom=6
    ),
)
        
layout2 = dict(
        #title = 'Network US city map',
        showlegend = True,
        geo = dict(
            scope='usa',
            projection=dict( type="albers usa" ),
            #center=dict(lon= -118.7559974,lat=36.7014631),
            showland = True,
            landcolor = 'rgb(217, 217, 217)',
            subunitwidth=1,
            countrywidth=1,
            subunitcolor="rgb(255, 255, 255)",
            countrycolor="rgb(255, 255, 255)"
        ),
    )

# change the layout based on preference
fig2 = dict(data=cities, layout=layout2)
#scatter_plot=dict(data=scatters,layout=layout_cal)
plotly.offline.plot(fig2, image='svg',validate=False, filename='usa-map.html')
#py.iplot(scatter_plot, filename='california-map.html')

#line map
stack3=[]
for i in range(len(state_map)):
    if data2['state'][i] != 'California':
        start_lat=state_map['latitude'][1]
        start_lon=state_map['longtitude'][1]
        end_lat=state_map['latitude'][i]
        end_lon=state_map['longtitude'][i]
        start='California'
        end=state_map['state'][i]
        stack3.append([start_lat,start_lon,end_lat,end_lon,start,end])
        
data3=pd.DataFrame(stack3,columns=['start_lat','start_lon','end_lat','end_lon','start','end'])

scale = 1.5

cities = [dict(
    type = 'scattergeo',
    locationmode = "USA-states",
    lon = state_map['longtitude'],
    lat = state_map['latitude'],
    text = state_map['text'],
    marker = dict(
        size = state_map['count']/scale,
        #sizeref = 2. * max(data['count']/scale) / (25 ** 2),
        color = [19]*len(state_map),
        sizemode = 'area',
        colorscale='Viridis'
    ),
    mode='Markers',
    showlegend=False)]


flight_paths = []
for i in range( len( data3 ) ):
    flight_paths.append(
        dict(
            type = 'scattergeo',
            locationmode = 'USA-states',
            lon = [ data3['start_lon'][i], data3['end_lon'][i] ],
            lat = [ data3['start_lat'][i], data3['end_lat'][i] ],
            mode = 'lines',
            line = dict(
                width = 0.7,
                color = 'rgb(130,223,220)',
            ),
        )
    )


layout3 = dict(
        #title = 'Network line map',
        showlegend = False, 
        geo = dict(
            scope='north america',
            projection=dict( type='albers usa' ),
            showland = True,
            subunitwidth=1,
            countrywidth=1,
            subunitcolor="rgb(255, 255, 255)",
            countrycolor="rgb(255, 255, 255)",
            landcolor = "rgb(217, 217, 217)"
        ),
    )
    
fig3 = dict( data=flight_paths + cities, layout=layout3 )
plotly.offline.plot(fig3, image='svg',validate=False, filename='line-bubble-map.html')
#py.iplot(fig3, validate=False, filename='line-bubble-map.html')

#world line map
stack4=[]
for i in range(len(data)):
    if data['country'][i] != 'USA':
        start_lat=data2['latitude'][1] #sf lat
        start_lon=data2['longtitude'][1] #sf long
        end_lat=data['latitude'][i]
        end_lon=data['longtitude'][i]
        start='San Francisco'
        end=data['country'][i]
        stack4.append([start_lat,start_lon,end_lat,end_lon,start,end])
        
data4=pd.DataFrame(stack4,columns=['start_lat','start_lon','end_lat','end_lon','start','end'])

world_data=data
world_data['longtitude'][0]=-122.4192363
world_data['latitude'][0]=37.7792808

scale = 5
countries = [dict(
    type = 'scattergeo',
    locationmode = "country names",
    lon = world_data['longtitude'],
    lat = world_data['latitude'],
    text = world_data['text'],
    marker = dict(
        size = world_data['count']/scale,
        #sizeref = 2. * max(data['count']/scale) / (25 ** 2),
        color = [19]*len(world_data),
        sizemode = 'area',
        colorscale='Viridis'
    ),
    mode='Markers',
    showlegend=False)]

world_flight_paths = []
for i in range( len( data4 ) ):
    world_flight_paths.append(
        dict(
            type = 'scattergeo',
            locationmode = 'country names',
            lon = [ data4['start_lon'][i], data4['end_lon'][i] ],
            lat = [ data4['start_lat'][i], data4['end_lat'][i] ],
            mode = 'lines',
            line = dict(
                width = 0.2,
                color = 'rgb(21,182,171)',
            ),
        )
    )


layout4 = dict(
        #title = 'World Network line map',
        showlegend = False, 
        geo = dict(
            scope='world',
            projection=dict( type="equirectangular"  ),
            showland = True,
            landcolor = 'rgb(243, 243, 243)',
            countrycolor = 'rgb(204, 204, 204)',
        ),
    )
    
fig4 = dict( data=world_flight_paths + countries, layout=layout4 )
plotly.offline.plot(fig4,image='svg', validate=False, filename='world-line-bubble-map.html')
#py.iplot(fig4, validate=False, filename='world-line-bubble-map.html')

