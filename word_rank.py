__author__ = 'root'

import os
import re
import sys
from os.path import basename

def ranking_similar_words(path, len_of_words):
    lines = readAllLine(path, 'ranking')
    fileName = 'ranking_with_leng_of_word_'+len_of_words+'.txt'
    fileResult = open(path+os.sep+fileName, 'w')
    fileResult.write('pattern|total_frequency |label|label_frequency|\n')
    list_all_words = dict()
    result = dict()
    aux_dict = dict()
    count = 0
    length = int(len_of_words)
    for line in lines:
        text = line.split('|')
        if count != 0 and len(text) == 4:
            connection = line.split('|')
            text = connection[3]
            status = clear_text(text)
            note = clear_text(connection[1])
            if len(status) > length:
                list_all_words[note] = all_word_list(status, length)
        count += 1
    for k in list_all_words.keys():
        build_word_ranking(result, list_all_words[k], k,aux_dict)

    # printing result
    d_view = [(v,k) for k,v in aux_dict.iteritems()]
    d_view.sort(reverse=True)
    for v,k in d_view:
        count = result[k][0]
        if count > 1:
            meta_data = ''
            dictMetaData = result[k][1]
            for k2 in dictMetaData.keys():
                meta_data = k2 + '|' + str(dictMetaData[k2])+'|'
            	result_line = k + '|' + str(count) + '|' + meta_data + '\n'
            	fileResult.write(result_line)

    fileResult.close()

def build_word_ranking(dic, list_words, idConnection, aux_dict):
    list_words.sort()
    for w in list_words:
        if w in dic:
            current_value = dic[w]
            current_value[0] += 1
            current_value[1][idConnection] = current_value[1][idConnection] + 1 if idConnection in current_value[1] else 1
            aux_dict[w] += 1
        else:
            dic[w] = [1, {idConnection: 1}]
            aux_dict[w] = 1
    return dic


def all_word_list(text, length):
    result = list()
    if len(text) < length:
        result.append(text)
        return result
    for idx in xrange(0, len(text)-length+1):
        result.append(text[idx:length+idx])
    return result

######## Auxiliar Method #########
def readAllLine(path, exclude=''):
    for file in os.listdir(path):
        if exclude != '':
            fileName = basename(file)
            if exclude not in fileName:
                with open(path+os.sep+file, 'r') as text:
                    for line in text:
                        yield line
        else:
            with open(path+os.sep+file, 'r') as text:
                for line in text:
                    yield line

def get_status(path, exclude=''):
    for line in readAllLine(path, exclude):
        if len(line)>1:
            yield line[3]

def clear_text(text,token=''):
    #Remove empty spaces
    text = re.sub(" +", "", text)
    text = re.sub("\n", "", text)
    if token != '':
        text = re.sub(token," ",text)
    return text

######### Making your script come true #########
if __name__ == "__main__":
    args = sys.argv[1:]
    if args[0] != '-d' or len(args) != 3:
        print 'Must supply directory name and a length of words to build e.g: "-d <dir-path> <number>"'
    else:
        ranking_similar_words(args[1], args[2])
    print 'done'
