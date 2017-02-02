#https://www.r-bloggers.com/inauguration-speeches/
#https://randomjohn.github.io/tidy-text-inauguration-speeches/

#Load data
data("data_corpus_inaugural", package='quanteda')
meta_data <- data.table::data.table(
  Year = data_corpus_inaugural$documents$Year,
  President = data_corpus_inaugural$documents$President,
  FirstName = data_corpus_inaugural$documents$FirstName
)

#Clean data
texts <- stringi::stri_trans_tolower(data_corpus_inaugural$documents$texts)
texts <- stringi::stri_replace_all_fixed(texts, "'t ", 't ')
texts <- stringi::stri_replace_all_regex(texts, '[[\\p{C}][\\p{M}][\\p{N}][\\p{P}][\\p{S}][\\p{Z}]]+', ' ')
texts <- stringi::stri_replace_all_regex(texts, ' +', ' ')
texts <- stringi::stri_trim_both(texts)
texts <- stringi::stri_split_fixed(texts, ' ')
texts <- lapply(texts, SnowballC::wordStem)
texts <- sapply(texts, stringi::stri_paste, collapse=' ')

#Vocabulary
it = text2vec::itoken(
  texts,
  preprocessor = stringi::stri_trans_tolower,
  tokenizer = function(x) stringi::stri_split_fixed(x, ' '),
  progressbar = FALSE)
vocab = text2vec::create_vocabulary(it, ngram = c(1L, 3L))
vocab = text2vec::prune_vocabulary(
  vocab,
  term_count_min = 10,
  doc_proportion_max = 0.98,
  doc_proportion_min = .2)
vocab$vocab[order(doc_counts),]

#To matrix
text_matrix = text2vec::create_dtm(it, text2vec::vocab_vectorizer(vocab))

#Save
devtools::use_data(text_matrix, overwrite=TRUE)
devtools::use_data(meta_data, overwrite=TRUE)
