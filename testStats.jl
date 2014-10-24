#! /usr/bin/env julia

function var_all(A)
	return 1/(length(A)) * sum((A-mean(A)).^2)
end

function var_iter(A)
	if length(A) > 1
		v_n_1 = var_all(A[1:end-1])
		v_n = 1/(length(A)-1)*(A[end] - mean(A)).^2 + (length(A)-1)/length(A)*v_n_1
		return v_n_1, v_n
	else
		println("no, no, get a bigger array")
	end
end
