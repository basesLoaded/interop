/** Simple statistics describing a set of metrics
 *
 *  @file
 *  @date  3/5/16
 *  @version 1.0
 *  @copyright GNU Public License.
 */
#pragma once

namespace illumina
{
namespace interop
{
namespace model
{
namespace summary
{

/** Simple statistics describing a set of metrics
 */
class metric_stat
{
public:
    /** Constructor
     *
     * @param mean mean value over several metrics
     * @param stddev standard deviation over several metrics
     * @param median median over several metrics
     */
    metric_stat(const float mean=0,
                const float stddev=0,
                const float median=0) :
            m_mean(mean),
            m_stddev(stddev),
            m_median(median)
    {
    }

public:
    /** Set the mean value
     *
     * @param val mean value
     */
    void mean(const float val)
    {
        m_mean = val;
    }
    /** Set the standard deviation value
     *
     * @param val standard deviation value
     */
    void stddev(const float val)
    {
        m_stddev = val;
    }
    /** Set the median value
     *
     * @param val median value
     */
    void median(const float val)
    {
        m_median = val;
    }

public:
    /** Get the mean value over several metrics
     *
     * @return mean value over several metrics
     */
    float mean()const
    {
        return m_mean;
    }
    /** Get the standard deviation over several metrics
     *
     * @return standard deviation over several metrics
     */
    float stddev()const
    {
        return m_stddev;
    }
    /** Get the median over several metrics
     *
     * @return median over several metrics
     */
    float median()const
    {
        return m_median;
    }
protected:
    /** Mean value */
    float m_mean;
    /** Standard deviation value */
    float m_stddev;
    /** Median value */
    float m_median;
};

}
}
}
}