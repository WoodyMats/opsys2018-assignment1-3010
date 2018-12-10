#!/bin/bash

#script1a.sh
eval var=1
if [ ! -f visited.txt ]; then
	touch visited.txt
	touch visitedsums.txt
	touch tmpFile.txt
fi

while read -r line; do
	[[ "$line" =~ ^#.*$ ]] && continue
	if grep -xq "$line" visited.txt ; then
		while read -r sum; do
			SUM_FOR_CHECK=$sum
			URL=$(wget -tries=5 -qO- "$line")
			CHECK=$(echo -n "$URL" | md5sum)
			if grep -xq "$CHECK $line" visitedsums.txt ; then
				echo "$line NOT UPDATED"
			else
				echo "$line UPDATED"
				sed "s~^.*$line~$CHECK $line~"  visitedsums.txt >> tmpFile.txt
                                cp tmpFile.txt visitedsums.txt
                                rm tmpFile.txt
			fi
			break
		done < "visitedsums.txt"

	else

                URL_INIT=$(wget -tries=5 -qO- "$line")
		if [ $? -ne 0 ]; then
			echo "$line FAILED"
		else
                        echo "$line INIT"
		fi	
		echo -n "$URL_INIT" | md5sum >> visitedsums.txt
                CHE=$(echo -n "$URL_INIT" | md5sum)
                if grep -xq "$CHE" visitedsums.txt ; then
        	        sed "s~$CHE~$CHE $line~"  visitedsums.txt >> tmpFile.txt
          		cp tmpFile.txt visitedsums.txt
        	        rm tmpFile.txt
         	fi
                        echo "$line" >> visited.txt
	fi
done < "$1"
