import pandas as pd
from wordcloud import WordCloud
import matplotlib.pyplot as plt
import sys

if len(sys.argv) != 3:
    print("Usage: python3 fakecloud.py <input_tsv> <langue>")
    sys.exit(1)

input_tsv = sys.argv[1] 
langue = sys.argv[2] 
output_png = f"wordcloud-{langue}.png" 

try:
    data = pd.read_csv(input_tsv, sep="\t", usecols=["token", "specificity"])
    word_freq = dict(zip(data['token'], data['specificity']))
except Exception as e:
    print(f"Error reading file: {e}")
    sys.exit(1)

wordcloud = WordCloud(
    width=1600,
    height=1000,
    background_color="white",
    colormap="inferno",  
    max_words=200,
    max_font_size=150,
    min_font_size=10,
)


wordcloud.generate_from_frequencies(word_freq)

plt.figure(figsize=(10, 10))
plt.imshow(wordcloud, interpolation="bilinear")
plt.axis("off")
plt.savefig(output_png)  
plt.show()
