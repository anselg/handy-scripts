:%s/\`\`/\"/g
:%s:\\texttt{\"\([^}]*\)\"}:<b>\1</b>:g
:%s:\\textbf{\"\([^}]*\)\"}:<b>\1</b>:g
:%s:\\textbf{\([^}]*\)}:<b>\1</b>:g
:%s:\\emph{\([^}]*\)}:<i>\1</i>:g
:%s:\\texttt{\([^}]*\)}:<code>\1</code>:g
:%s:\\subsection{\([^}]*\)}:<h5\ class="page-header">\1</h5>:g
:%s/\\ref{[^}]*}//g
:%s/\$\\rightarrow\$/\ -->\ /g
:%s/\$\\leftarrow\$/\ <--\ /g
:%s/\\attention\ //g
:%s/\\marginlabel{[^}]*}//g
:%s/\\index{[^}]*}//g
:%s/\\seealso{[^}]*}//g
:%s/\\begin{[^}]*}/{% highlight bash %}/g
:%s/\\end{[^}]*}/{% endhighlight %}/g
:%s/\\\\//g

":%s/\\//g <-- maybe...
