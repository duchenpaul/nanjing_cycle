temp_folder='/home/pi/run/test/nanjing_cycle/temp'
tmp=${temp_folder}/nanjing_cycle.tmp
tmp_2=${temp_folder}/nanjing_cycle.tmp_2

data_file_tmp=${temp_folder}/nanjing_cycle_station.dat_tmp
data_file=${temp_folder}/nanjing_cycle_station.dat

get_value()
{
	#echo  $1 | cut -d "{" -f2 | cut -d "}" -f1 | sed 's/,/\n/g' | grep $2 | awk -F "\"" '{print $4}'
	echo  $1  | sed 's/,/\n/g' | grep $2 | awk -F "\"" '{print $4}'
}

curl -s -o $tmp -X POST \
-H "Cache-Control: no-cache" \
-H "Postman-Token: 31a90871-ce94-d148-5dc0-f362d3a58615" \
-H "Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW" \
-F "longitude=118.748425" -F "latitude=32.066617" -F "diameter=120000" \
"http://58.213.141.220:10001/greentravel-api/getBicycleSpotsWithinCenter" 

echo "Started: `date`" >> ./LOG

cat  $tmp | cut -d "[" -f2 | cut -d "]" -f1 > $tmp_2
sed -i 's/,{/,\n{/g' $tmp_2
head -10 $tmp_2 > ${temp_folder}/test.tmp

# stationName=`get_value ${LINE} stationName`
# latitude=`get_value ${LINE} latitude`
# longitude=`get_value ${LINE} longitude`
# vacanciesCount=`get_value ${LINE} vacanciesCount`
# availableCount=`get_value ${LINE} availableCount`

# echo "{title: \"名称：${stationName}\", point: \"${longitude},${latitude}\", address: \"Vacencies: ${vacanciesCount}\", tel: \"Available: ${availableCount}\"},\n  " > ${temp_folder}/test_conv.tmp

# cat ${temp_folder}/test_conv.tmp

rm -fr $data_file_tmp

FILE=$tmp_2

#  test switch
#FILE=${temp_folder}/test.tmp

while read LINE; do
    stationName=`get_value ${LINE} stationName`
	latitude=`get_value ${LINE} latitude`
	longitude=`get_value ${LINE} longitude`
	vacanciesCount=`get_value ${LINE} vacanciesCount`
	availableCount=`get_value ${LINE} availableCount`
	echo "{\"title\": \"名称：${stationName}\", \"point\": \"${longitude},${latitude}\", \"Vacencies\": \"${vacanciesCount}\", \"Available\": \"${availableCount}\"}," >> $data_file_tmp

done < "$FILE"

sed -i 's/}$//g'  $data_file_tmp #de-trash data, those not end up with ','
# sed -i '$ s/.$//' $data_file_tmp

#add baracket in the data
sed -i -e '1s/^/[/'  -e '$s/,$/]/' $data_file_tmp

#merge all records into 1 line
paste -d ' ' -s  $data_file_tmp > ${data_file_tmp}_tmp 
mv ${data_file_tmp}_tmp $data_file_tmp

mv $data_file_tmp $data_file
sudo cp $data_file /var/www

echo "Completed: `date`" >> ./LOG
