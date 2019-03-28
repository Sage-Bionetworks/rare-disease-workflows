'''
This is a short script that takes a list of specimenIDs and a list of files, and a manifest and matches the manifest to create a new one

'''

import pandas
import sys
import argparse
import os


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
        '-v',
        '--values',
        type=str,
        nargs='+',
        required=True,
        help='Values by which you would like to join the synapse ids')

    parser.add_argument(
        '-k',
        '--key',
        type=str,
        default='specimenID',
        help='Key on which you want to join')

    parser.add_argument(
        '-u',
        '--used',
        type=str,
        nargs='+',
        required=False,
        help='List of synapse ids used in this analysis')

    parser.add_argument(
        '-e',
        '--executed',
        type=str,
        nargs='+',
        required=False,
        help='List of files used to execute this')

    args = parser.parse_args()

    if(len(args.values)!=len(args.filelist)):
        print('specimcenIds and synids need to be the same length')

    #read in manifest
    manifest=pandas.read_csv(args.manifest_file,sep='\t')

    #join specimens and synids into data frame
    specToSyn=pandas.DataFrame({'specimenID':args.specimenIds,'path': [os.path.basename(a) for a in args.filelist]})


    #add in parent id
    specToSyn['parent']=args.parentId

    ##add in provenance
    if args.used is not None:
        specToSyn['used']=args.used.join(',') ##what is the delimiter?
    if args.executed is not None:
        specToSyn['executed']=args.executed.join(',')

    #join entire dataframe
    full_df=specToSyn.merge(manifest, on=args.key)

    full_df.to_csv('new_manifest.tsv',sep='\t',index=False)
