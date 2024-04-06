#make a small example of using threads in julia to process an array parallelly
function test_threads()
    n = 10
    a = zeros(n)
    start = time()
    Threads.@threads for i = 1:n
        sleep(10)
        #print seconds past since the start of the program
        println(time()-start)
        a[i] = Threads.threadid()
    end
    println(a)
end

test_threads()