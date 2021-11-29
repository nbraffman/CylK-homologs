#!/bin/sh
filename='input_all_homologs.fasta'
Counter=0
rm out_homologs.fasta
while read line; do
    if [ $Counter -eq 0 ]; then #copy first line metadata of fasta file to temp.txt
        metadata=$line          #copy name to variable for log output
        echo $line > temp.txt
        echo $line > temp.fasta
        Counter=$((Counter+1)) #increase counter index to proceed to second line
    else
        echo $line >> temp.txt #copy second line sequence data to temp.txt
        echo $line >> temp.fasta #secondary copy for binning
        Counter=$((Counter-1)) #decrease counter index back to 0 to reset for next sequence
        
        filename='licheniforme.fasta'   #in the meantime... while we are on each sequence data line:
        while read line; do
            echo $line >> temp.txt      #copy reference metadata and sequence to temp.txt 
        done < 'licheniforme.fasta'

        muscle -in temp.txt -out temp.afa   #run muscle alignment of sequence against ref, output temp.afa

        filename='temp.afa'     #open temp.afa
        Counter2=0
        while read line; do
            Counter2=$((Counter2+1))    #determine number of lines because it will vary between alignments
        done < 'temp.afa'

        filename='temp.afa'     #re-open temp.afa
        Counter3=0
        homolog=""              #define variables homolog and refseq to exract data as strings from alignment
        refseq=""
        while read -r line; do          #very important to have -r here to recognize carriage returns
            Counter3=$((Counter3+1))

            if [ $Counter3 -eq 1 ]; then #at first line of alignment file, skip metadata
                echo
            else                                                #at all other lines
                if [ $Counter3 -le $((Counter2/2)) ]; then      #if we are in the first half of text file (homolog of interest)
                homolog="$homolog$line"                         #conatenate string to remove returns
                else
                    if [ $Counter3 -gt $((Counter2/2+1)) ]; then    #at all other lines second half of text file (reference seq)
                        refseq="$refseq$line"                       #concatenate string to remove returns
                    fi
                fi
            fi
            #echo $homolog > temp2.txt #write extracted strings to temp2.txt and temp3.txt for analysis
            #echo $refseq > temp3.txt
        done < 'temp.afa'

        hash_counter=0                                      #define variable to count breaks in alignment from left to right
        for (( i=0; i<${#refseq}; i++ )); do                #iterate through reference sequence (string)
            if [ $i -le $((hash_counter+240)) ]; then       #continue until the index is <= the number of breaks + 240
                if [ "${refseq:$i:1}" = "-" ]; then         #this is how we are defining the N-terminus, containing something between R105 and K240
                    hash_counter=$(($hash_counter+1))
                fi
            fi
        done
        echo "Query Sequence: "$metadata
        echo "N-Terminal breaks in ref sequence: "$hash_counter
        
        hash_counter2=0
        index=0
        for (( i=0; i<${#homolog}; i++ )); do              #repeat with homolog sequence (string) for the index length as above
            if [ $i -le $((hash_counter+240)) ]; then      #NOTE this should be hash_counter not hash_counter2
                index=$(($index+1))
                if [ "${homolog:$i:1}" = "-" ]; then        
                    hash_counter2=$(($hash_counter2+1))    #but do keep track of hash count in this sequence for analysis
                fi
            fi
        done
        echo "N-terminal breaks in query sequence: "$hash_counter2
        echo "# of residues before K240 equivalent: "$((index-hash_counter2))

        if [ $((index-hash_counter2+hash_counter)) -ge 135  ]; then
            filename='temp.fasta'
            while read line; do
                echo $line >> out_homologs.fasta
            done <'temp.fasta'
        fi
    fi
done < 'input_all_homologs.fasta'

rm temp.fasta
rm temp.afa
rm temp.txt

