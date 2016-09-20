require 'sidekiq/api'

module Sidekiq
  class Queue
    def self.job_exists?(params, options ={})
      queue = Sidekiq::Queue.new(params[:queue])
      return false unless queue

      queue.detect do |job|
        _same_job = job.display_class.eql? "#{params[:class]}.#{params[:routine]}"
        _same_parameters = job.display_args == params[:parameters]

        return true if _same_job and _same_parameters
      end
      false
    end
  end
  class Workers
    def self.currently_working
      _working_jobs = []
      Sidekiq::Workers.new.each do |process, thread, message|
        _job = Sidekiq::Job.new(message['payload'])
        _working_jobs << {started_at: Time.at(message['run_at']), job_name: _job.display_class, job_args: _job.display_args}
      end
      _working_jobs
    end

    def self.job_running?(params, options ={})
      Sidekiq::Workers.new.each do |process, thread, message|
        job = Sidekiq::Job.new(message['payload'])

        _same_job = job.display_class.eql? "#{params[:class]}.#{params[:routine]}"
        _same_parameters = job.display_args == params[:parameters]
        return true if _same_job and _same_parameters
      end

      false
    end

  end
end