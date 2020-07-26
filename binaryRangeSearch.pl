#!/usr/bin/perl
use strict;
use warnings;
no warnings 'recursion';
use Data::Dumper;

#************************************************************************************************
#Author: abains-src                                                                           *
#Purpose: Range search algorithm exercise with references                                       *
#************************************************************************************************

#Pseudocode for binary range search
my $pseudocode =<<'DOC';
user query = $needle

Calculate first and last index in array

If the length of array is not 0, execute binary search
    Calculate length of array using first and last index
    Calculate middle value by taking the average of the first and last index
    If length is 0, return nothing
    
    If middle value is greater than the user query, recurse subroutine using subarray between middle and last value
    If middle value is less than the user query, recurse subroutine using subarray between 0 and middle value
    
    If middle value (originmiddle) is equal to user query
        Compare array element at middle-1 with query
        
        If they do not equal, run a search sub for the first index
            Calculate a new middle value between 0 and middle element
                Execute new recursive binary search subroutine until middle element = query and middle-1 does not equal query
                    If new middle value is greater than the user query, recurse subroutine using subarray between new middle and originmiddle value
                    If new middle value is less than the user query, recurse subroutine using subarray between 0 and new middle value
                    If array length = 0, return nothing
                    Store this value (value = lower limit)
                    
                    If the originmiddle+1 equals query
                        Calculate a new middle value between originmiddle and last element in array
                        If length is zero, return lower limit, originmiddle
                            Execute new recursive binary search subroutine until middle element = query and middle+1 does not equal query
                                If new middle value is greater than the user query, recurse subroutine using subarray between new middle and last value
                                If new middle value is less than the user query, recurse subroutine using subarray between 'lower limit' and new middle value
                                Store this value (value = upper limit)
                                Return lower limit, upper limit+1
                                
                Else if the originmiddle+1 does not equal query
                    Return lower limit, originmiddle+1
                    
        Else if originmiddle is the only value (thus, has a range of 1)
            Return originmiddle, originmiddle+1
            
End Program

DOC

#Recursive binary range search with references
#Input:
#   $scalar
#   @array reference
#Output:
#   Returns the range of indices where the match resides if there is a match
#   Returns nothing if there is no match
#@array must be sorted in numerical order
#This subroutine calculates the first and last indices of array before search
#then it executes the search using an internal subroutine.

sub binary_range_search{
    my ($scalar, $arrayref) = ($_[0], $_[1]);
    
    #Calculates first and last elements of the haystack array
    my ($firstindex, $lastindex) = (0, @$arrayref - 1);
    
    #Runs search subroutine if there is at least one element in the array
    if ($lastindex+1 != 0) {
        return _binary_search($scalar, $arrayref, $firstindex, $lastindex);
    }
    
    #Primary binary search subroutine
    sub _binary_search{
        my ($needle, $haystack, $firstindex, $lastindex)= ($_[0], $_[1], $_[2], $_[3]);
        
        #Calculate length and middle index of array
        my $length = $lastindex - $firstindex;
        my $mid = int(($lastindex + $firstindex)/2);
        
        #Base case, return nothing if the length of array reaches 0 or lower
        #and if the middle element does not equal $needle
        if ($length <= 0 && $haystack->[$mid] != $needle) {
            return;
        }

        #Finds index when middle element is equal to query
        if ($haystack->[$mid] == $needle) {
            #if $needle is equal to middle element, search for first and last indices
            if ($haystack->[$mid-1] == $needle) {
                #search for the first index in the query range
                return binary_search_first($needle, 0, $mid, $haystack, $mid);
            } elsif ($haystack->[$mid+1] == $needle){
                #if found index is the first in its range
                return binary_search_last($needle, $mid, $lastindex, $haystack, $mid, $mid);
            } else {
                #if the found index has a range of 1
                return $mid, ", ", $mid+1, "\n";
            }
            
            #subroutine which searches for the first index in range
            sub binary_search_first {
                my ($needle2, $first, $last, $haystack2, $originalmid) = ($_[0], $_[1], $_[2], $_[3], $_[4]);
                
                my $mid2 = int(($first+$last)/2);
                my $length = @$haystack2 - 1;
                
                if ($length <= 0) {
                    return;
                }
                
                #if first index in range is found, execute search for last index
                if ($haystack2->[$mid2] == $needle2 && $haystack2->[$mid2-1] != $needle2) {
                    if ($haystack2->[$originalmid+1] == $needle2) {
                        #if found index is NOT the first in its range
                        return binary_search_last($needle2, $mid2, $length, $haystack2, $originalmid, $mid2);
                        
                        #subroutine which searches for last index in range
                        sub binary_search_last {
                            my ($needle2, $first, $last, $haystack2, $originmid, $firstindex) = ($_[0], $_[1], $_[2], $_[3], $_[4], $_[5]);
                            my $mid2 = int(($first+$last)/2);
                            my $length = @$haystack2 - 1;
                            
                            if ($length <= 0) {
                                return $firstindex, ", ", $originmid, "\n";
                            }
                            
                            if ($haystack2->[$mid2] == $needle2 && $haystack2->[$mid2+1] != $needle2) {
                                #if last index is found, return it with the first index
                                return $firstindex, ", ", $mid2+1, "\n";
                            } elsif ($haystack2->[$mid2] > $needle2) {
                                #if $needle is less than the middle element, search first half of @haystack2
                                return binary_search_last($needle2, $firstindex, $mid2, $haystack2, $originmid, $firstindex);
                            } elsif ($haystack2->[$mid2] < $needle2) {
                                #if $needle is greater than the middle element, search last half of @haystack2
                                return binary_search_last($needle2, $mid2, $last, $haystack2, $originmid, $firstindex); 
                            } elsif ($haystack2->[$mid2] == $needle2 && $haystack2->[$mid2+1] == $needle2) {
                                #if $needle is equal, but NOT the last index, search again using current index as lower limit
                                return binary_search_last($needle2, $mid2, $last, $haystack2, $originmid, $firstindex);
                            }
                        }
                    } else {
                        #if the original query found is the last index in range
                        return $mid2, ", ", $originalmid+1, "\n";
                    }
                    
                } elsif ($haystack2->[$mid2] > $needle2) {
                    #if $needle is less than the middle element, search first half of @haystack
                    return binary_search_first($needle2, 0, $mid2, $originalmid);
                } elsif ($haystack2->[$mid2] < $needle2) {
                    #if $needle is greater than the middle element, search last half of @haystack
                    return binary_search_first($needle2, $mid2, $last, $haystack2, $originalmid); 
                } elsif ($haystack2->[$mid2] == $needle2 && $haystack2->[$mid2-1] == $needle2) {
                    #if $needle is equal, but NOT the last index, search again using current index as lower limit
                    return binary_search_first($needle2, 0, $mid2, $haystack2, $originalmid);
                }
            }
            
        } elsif ($haystack->[$mid] > $needle) {
            #if $needle is less than the middle element, search first half of @haystack
            return _binary_search($needle, $haystack, 0, $mid);
        } elsif ($haystack->[$mid] < $needle) {
            #if $needle is greater than the middle element, search last half of @haystack
            return _binary_search($needle, $haystack, $mid+1, $lastindex); 
        }   
    }
}
