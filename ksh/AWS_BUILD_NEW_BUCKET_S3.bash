
# nettoyage ancien bucket s3
aws s3 rm s3://mon-bucket-transfert-$(date +%s)/ --recursive

# create new bucket
aws s3 mb s3://mon-bucket-transfert-$(date +%s)
