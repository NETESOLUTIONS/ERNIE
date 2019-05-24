CREATE TABLE hoteldata AS SELECT xml
$$<hotels>
 <hotel id="mancha">
  <name>La Mancha</name>
  <rooms>
   <room id="201"><capacity>3</capacity><comment>Great view of the Channel</comment></room>
   <room id="202"><capacity>5</capacity></room>
  </rooms>
  <personnel>
   <person id="1025">
    <name>Ferdinando Quijana</name><salary currency="PTA">45000</salary>
   </person>
  </personnel>
 </hotel>
  <hotel id="valpo">
  <name>Valparaíso</name>
  <rooms>
   <room id="201"><capacity>2</capacity><comment>Very noisy</comment></room>
   <room id="202"><capacity>2</capacity></room>
  </rooms>
  <personnel>
   <person id="1026"><name>Katharina Wuntz</name><salary currency="EUR">50000</salary></person>
   <person id="1027"><name>Diego Velázquez</name><salary currency="CLP">1200000</salary></person>
  </personnel>
 </hotel>
</hotels>$$ AS hotels;

SELECT xmltable.*
  FROM hoteldata,
       XMLTABLE ('/hotels/hotel/rooms/room' PASSING hotels
                 COLUMNS
                    id FOR ORDINALITY,
                    hotel_name text PATH '../../name' NOT NULL,
                    room_id int PATH '@id' NOT NULL,
                    capacity int,
                    comment text PATH 'comment' DEFAULT 'A regular room'
                );