#!/bin/bash

# lister tous les buckets 
aws s3api list-buckets --query "Buckets[].Name" --output text

# afficher tous les buckets selon critère (filtre)
for bucket in $(aws s3api list-buckets --query "Buckets[].Name" --output text); do
    if [[ $bucket == *"transfert"* ]]; then
        echo $bucket
    fi
done


# vidage et suppression du bucket selon filtre 
for bucket in $(aws s3api list-buckets --query "Buckets[].Name" --output text); do
    if [[ $bucket == *"transfert"* ]]; then
        echo "Suppression du contenu de $bucket..."
        aws s3 rm s3://$bucket --recursive
        echo "Suppression du bucket $bucket..."
        aws s3api delete-bucket --bucket $bucket
    fi
done

