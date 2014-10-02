npIDR
=====

Non-parametric IDR estimation

This repository contains translations of npIDR script (funIDRnpFile.m) by Alex Dobin to R and to Perl.

It essentially takes a pooled sample of all replicas and computes

	(a) the frequency of seeing count=x;
	(b) the frequency of seeing count=x given that in *ALL* other replicas the count is equal to zero

The ratio of the two frequencies is called npIDR. Originally it was designed for two bioreplicates but with 
the word 'ALL' above it works for any number of them.

A few questions remain:

	(1) does it have to be integer frequencies or probabilities? 
	(2) are matrices in matlab indexed starting from 0 or from 1? If the latter then there will be a shift of 1, where npIDR value of count=2 will be actually taken for the conditional probability of count=1
