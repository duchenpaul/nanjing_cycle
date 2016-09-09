tmp=./temp/nanjing_cycle.tmp
tmp_2=./temp/nanjing_cycle.tmp_2

data_file_tmp=./temp/nanjing_cycle_station.dat_tmp
data_file=./temp/nanjing_cycle_station.dat

# curl -s -o $tmp -X POST \
# -H "Cache-Control: no-cache" \
# -H "Postman-Token: 31a90871-ce94-d148-5dc0-f362d3a58615" \
# -H "Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW" \
# -F "longitude=118.748425" -F "latitude=32.066617" -F "diameter=120000" \
# "http://58.213.141.220:10001/greentravel-api/getBicycleSpotsWithinCenter" 

echo "Started: `date`" >> ./LOG

cat  $tmp | cut -d "[" -f2 | cut -d "]" -f1 > $tmp_2
sed -i 's/,{/,\n{/g' $tmp_2
head -10 $tmp_2 > ./temp/test.tmp

get_value()
{
	#echo  $1 | cut -d "{" -f2 | cut -d "}" -f1 | sed 's/,/\n/g' | grep $2 | awk -F "\"" '{print $4}'
	echo  $1  | sed 's/,/\n/g' | grep $2 | awk -F "\"" '{print $4}'
}

# stationName=`get_value ${LINE} stationName`
# latitude=`get_value ${LINE} latitude`
# longitude=`get_value ${LINE} longitude`
# vacanciesCount=`get_value ${LINE} vacanciesCount`
# availableCount=`get_value ${LINE} availableCount`

# echo "{title: \"名称：${stationName}\", point: \"${longitude},${latitude}\", address: \"Vacencies: ${vacanciesCount}\", tel: \"Available: ${availableCount}\"},\n  " > ./temp/test_conv.tmp

# cat ./temp/test_conv.tmp

rm -fr $data_file_tmp

FILE=$tmp_2
#FILE=./temp/test.tmp
while read LINE; do
    stationName=`get_value ${LINE} stationName`
	latitude=`get_value ${LINE} latitude`
	longitude=`get_value ${LINE} longitude`
	vacanciesCount=`get_value ${LINE} vacanciesCount`
	availableCount=`get_value ${LINE} availableCount`
	echo "{title: \"名称：${stationName}\", point: \"${longitude},${latitude}\", Vacencies: \"${vacanciesCount}\", Available: \"${availableCount}\"}," >> $data_file_tmp

done < "$FILE"

sed -i 's/}$//g'  $data_file_tmp #de-trash data, those not end up with ','
sed -i '$ s/.$//' $data_file_tmp
mv $data_file_tmp $data_file

echo "Completed: `date`" >> ./LOG
