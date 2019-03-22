'''
This is a short script that takes a list of specimenIDs and a list of files, and a manifest and matches the manifest to create a new one

'''

import pandas
import sys
import argparse


if __name__ == '__main__':

    parser = argparse.ArgumentParser("Merges array of synids with other annotations, adds parent and returns new manifest")

    parser.add_argument(
            '-m',
            '--manifest_file',
            type = str,
            required=True)

    parser.add_argument(
            '-f',
            '--filelist',
            type = str,
            nargs='+',
            required=True)

    parser.add_argument(
        '-p',
        '--parentId',
        type= str,
        required=True)

    parser.add_argument(
        '-s',
        '--specimenIds',
        type=str,
        nargs='+',
        required=True)


    args = parser.parse_args()

    if(len(args.specimenIds)!=len(args.filelist)):
        print('specimcenIds and synids need to be the same length')

    #read in manifest
    manifest=pandas.read_csv(args.manifest_file,sep='\t')

    #join specimens and synids into data frame
    specToSyn=pandas.DataFrame({'specimenID':args.specimenIds,'path':args.filelist})

    #add in parent id #syn18457550
    specToSyn['parentId']=args.parentId

    #join entire dataframe
    full_df=specToSyn.merge(manifest, on='specimenID')

    full_df.to_csv('new_manifest.tsv',sep='\t',index=False)
